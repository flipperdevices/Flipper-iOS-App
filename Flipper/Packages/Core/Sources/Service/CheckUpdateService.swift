import Inject
import Analytics
import Peripheral

import Logging
import Combine
import Foundation

@MainActor
// swiftlint:disable type_body_length
public class CheckUpdateService: ObservableObject {
    private let appState: AppState

    var update: UpdateModel {
        get { appState.update }
        set { appState.update = newValue }
    }

    var updateAvailable: VersionUpdateModel {
        get { appState.updateAvailable }
        set { appState.updateAvailable = newValue }
    }

    @Inject private var rpc: RPC
    private var disposeBag: DisposeBag = .init()

    @Published var flipper: Flipper? {
        didSet { onFlipperChanged(oldValue) }
    }

    var hasManifest: LazyResult<Bool, Swift.Error> = .idle
    var currentRegion: LazyResult<ISOCode, Swift.Error> = .idle
    var provisionedRegion: LazyResult<ISOCode, Swift.Error> = .idle

    var hasSDCard: LazyResult<Bool, Swift.Error> {
        guard let storage = flipper?.storage else { return .working }
        return .success(storage.external != nil)
    }

    public var hasBatteryCharged: Bool {
        guard let battery = flipper?.battery else { return false }
        return battery.level >= 10 || battery.state == .charging
    }

    public init(appState: AppState) {
        self.appState = appState
        subscribeToPublishers()
    }

    func subscribeToPublishers() {
        appState.$flipper
            .receive(on: DispatchQueue.main)
            .assign(to: \.flipper, on: self)
            .store(in: &disposeBag)
    }

    func onFlipperChanged(_ oldValue: Flipper?) {
        updateState(channel: updateAvailable.selectedChannel)

        guard flipper?.state == .connected else {
            resetState()
            return
        }

        if oldValue?.state != .connected {
            verifyManifest()
            verifyRegionData()
            detectCurrentRegion()
        }

        verifyUpdateResult()
    }

    public func onUpdatePressed() {
        guard
            let installed = updateAvailable.installed,
            let available = updateAvailable.available
        else {
            return
        }

        updateAvailable.intent = .init(
            id: Int(Date().timeIntervalSince1970),
            from: installed,
            to: available
        )
    }

    public func onUpdateStarted(_ intent: Update.Intent) {
        // FIXME: wait for event
        updateAvailable.state = .busy(.updateInProgress(intent))
        // FIXME: reuse updateAvailable.state
        update.inProgress = intent
    }

    func resetState() {
        hasManifest = .idle
        currentRegion = .idle
        provisionedRegion = .idle
    }

    func verifyManifest() {
        guard case .idle = hasManifest else { return }
        hasManifest = .working
        Task {
            do {
                _ = try await rpc.getSize(at: .manifest)
                hasManifest = .success(true)
            } catch {
                logger.error("verify manifest: \(error)")
                hasManifest = .success(false)
            }
        }
    }

    func verifyRegionData() {
        guard case .idle = provisionedRegion else { return }
        provisionedRegion = .working
        Task {
            do {
                let bytes = try await rpc.readFile(at: Provisioning.location)
                let region = try Provisioning.Region(decoding: bytes)
                provisionedRegion = .success(region.code)
            } catch {
                logger.error("verify region: \(error)")
                provisionedRegion = .failure(error)
            }
        }
    }

    func detectCurrentRegion() {
        guard case .idle = currentRegion else { return }
        currentRegion = .working
        Task {
            do {
                let region = try await Provisioning().provideRegion().code
                currentRegion = .success(region)
            } catch {
                logger.error("check region change: \(error)")
                currentRegion = .failure(error)
            }
        }
    }

    func verifyUpdateResult() {
        guard
            let intent = update.inProgress,
            let installed = updateAvailable.installed
        else {
            return
        }

        update.inProgress = nil

        var updateFromToVersion: String {
            "from \(intent.from) to \(intent.to)"
        }

        Task {
            // FIXME: ignore GATT cache
            try await Task.sleep(milliseconds: 333)

            if intent.to.description == installed.description {
                logger.info("update success: \(updateFromToVersion)")

                update.result.send(.success)

                analytics.flipperUpdateResult(
                    id: intent.id,
                    from: intent.from.description,
                    to: intent.to.description,
                    status: .completed)
            } else {
                logger.info("update error: \(updateFromToVersion)")

                update.result.send(.failure)

                analytics.flipperUpdateResult(
                    id: intent.id,
                    from: intent.from.description,
                    to: intent.to.description,
                    status: .failed)
            }
        }
    }

    public func onNetworkStatusChanged(available: Bool) {
        switch available {
        case true: updateAvailable.state = .busy(.connecting)
        case false: updateAvailable.state = .error(.noInternet)
        }
    }

    public func onChannelSelected(_ channel: String) {
        switch channel {
        case "Release": updateAvailable.selectedChannel = .release
        case "Release-Candidate":  updateAvailable.selectedChannel = .candidate
        case "Development":  updateAvailable.selectedChannel = .development
        default: break
        }
        updateVersion(for:  updateAvailable.selectedChannel)
    }

    public func onCustomURLOpened(url: URL) {
        updateAvailable.selectedChannel = .custom(url)
    }

    public func updateAvailableFirmware() {
        Task {
            do {
                guard update.state != .error(.noInternet) else { return }
                updateAvailable.manifest = try await Update.Manifest.download()
                updateVersion(for: updateAvailable.selectedChannel)
            } catch {
                update.state = .error(.cantConnect)
                logger.error("download manifest: \(error)")
            }
        }
    }

    public func updateVersion(for channel: Update.Channel) {
        guard
            let firmware = updateAvailable.manifest?.version(for: channel)
        else {
            updateAvailable.available = nil
            return
        }

        updateAvailable.available = .init(
            channel: channel,
            firmware: firmware)

        updateState(channel: channel)
    }

    // Validating

    func updateState(channel: Update.Channel) {
        guard validateFlipperState() else { return }
        guard validateSDCard() else { return }

        guard validateInstalledFirmware() else { return }
        guard validateAvailableFirmware() else { return }

        guard checkSelectedChannel(channel) else { return }
        guard checkInstalledFirmware() else { return }

        guard validateManifest() else { return }
        guard validateRegion() else { return }

        updateAvailable.state = .ready(.noUpdates)
    }

    func validateFlipperState() -> Bool {
        guard let flipper = flipper else { return false }

        switch flipper.state {
        case .connected:
            return true
        case .connecting:
            switch updateAvailable.state {
            case .error(.noCard), .busy(.updateInProgress):
                return false
            default:
                updateAvailable.state = .busy(.connecting)
                return false
            }
        default:
            switch updateAvailable.state {
            case .busy(.updateInProgress):
                return false
            default:
                updateAvailable.state = .error(.noDevice)
                return false
            }
        }
    }

    func validateSDCard() -> Bool {
        guard case .success(let hasSDCard) = hasSDCard else {
            return false
        }
        guard hasSDCard else {
            updateAvailable.state = .error(.noCard)
            return false
        }
        return true
    }

    func validateManifest() -> Bool {
        guard case .success(let hasManifest) = hasManifest else {
            return false
        }
        guard hasManifest else {
            updateAvailable.state = .ready(.versionUpdate)
            return false
        }
        return true
    }

    func validateRegion() -> Bool {
        let provisionedRegionCode: ISOCode
        let currentRegionCode: ISOCode

        switch provisionedRegion {
        case .success(let region):
            provisionedRegionCode = region
        case .failure:
            updateAvailable.state = .ready(.versionUpdate)
            return false
        default:
            return false
        }

        switch currentRegion {
        case .success(let region):
            currentRegionCode = region
        case .failure:
            updateAvailable.state = .ready(.versionUpdate)
            return false
        default:
            return false
        }

        guard currentRegionCode == provisionedRegionCode else {
            updateAvailable.state = .ready(.versionUpdate)
            return false
        }

        return true
    }

    func validateInstalledFirmware() -> Bool {
        guard let installed = flipper?.information?.firmwareVersion else {
            updateAvailable.installed = nil
            return false
        }
        updateAvailable.installed = installed
        return true
    }

    func validateAvailableFirmware() -> Bool {
        return updateAvailable.available != nil
    }

    func checkSelectedChannel(_ channel: Update.Channel) -> Bool {
        guard let installed = updateAvailable.installed else {
            return false
        }
        guard installed.channel == channel else {
            updateAvailable.state = .ready(.channelUpdate)
            return false
        }
        return true
    }

    func checkInstalledFirmware() -> Bool {
        guard
            let installed = updateAvailable.installed,
            let available = updateAvailable.available
        else {
            return false
        }
        guard installed.description == available.description else {
            updateAvailable.state = .ready(.versionUpdate)
            return false
        }
        return true
    }
}
