import Inject
import Analytics
import Peripheral

import Logging
import Combine
import Foundation

@MainActor
// swiftlint:disable type_body_length
public class CheckUpdateService: ObservableObject {
    private let logger = Logger(label: "check-update-service")

    private let appState: AppState
    private let flipperService: Core.FlipperService

    var update: Update {
        get { appState.update }
        set { appState.update = newValue }
    }

    var updateAvailable: VersionUpdateModel {
        get { appState.updateAvailable }
        set { appState.updateAvailable = newValue }
    }

    @Inject private var rpc: RPC
    @Inject var analytics: Analytics
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

    public init(appState: AppState, flipperService: FlipperService) {
        self.appState = appState
        self.flipperService = flipperService
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

    public func updateStorageInfo() {
        Task { await updateStorageInfo() }
    }

    func verifyUpdateResult() {
        guard
            let intent = update.intent,
            let installed = updateAvailable.installed
        else {
            return
        }

        update.intent = nil

        var updateFromToVersion: String {
            "from \(intent.from) to \(intent.to)"
        }

        Task {
            // FIXME: ignore GATT cache
            try await Task.sleep(milliseconds: 333)

            if intent.to.description == installed.description {
                logger.info("update success: \(updateFromToVersion)")

                update.result = .completed

                analytics.flipperUpdateResult(
                    id: intent.id,
                    from: intent.from.description,
                    to: intent.to.description,
                    status: .completed)
            } else {
                logger.info("update error: \(updateFromToVersion)")

                update.result = .failed

                analytics.flipperUpdateResult(
                    id: intent.id,
                    from: intent.from.description,
                    to: intent.to.description,
                    status: .failed)
            }
        }
    }

    func updateStorageInfo() async {
        // swiftlint:disable statement_position
        do { try await flipperService.updateStorageInfo() }
        catch { logger.error("update storage info: \(error)") }
    }

    public func onNetworkStatusChanged(available: Bool) {
        switch available {
        case true: updateAvailable.state = .busy(.connecting)
        case false: updateAvailable.state = .error(.noInternet)
        }
    }

    public func updateAvailableFirmware(for channel: Update.Channel) {
        Task {
            do {
                guard update.state != .error(.noInternet) else { return }
                updateAvailable.manifest = try await update.downloadManifest()
                updateVersion(for: channel)
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
            if
                updateAvailable.state != .error(.noInternet),
                updateAvailable.state != .busy(.updateInProgress)
            {
                updateAvailable.state = .busy(.connecting)
            }
            return false
        default:
            if updateAvailable.state != .busy(.updateInProgress) {
                updateAvailable.state = .error(.noDevice)
            }
            return false
        }
    }

    func validateSDCard() -> Bool {
        guard case .success(let hasSDCard) = hasSDCard else {
            updateAvailable.state = .busy(.connecting)
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
            updateAvailable.state = .busy(.connecting)
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
            updateAvailable.state = .busy(.connecting)
            return false
        }

        switch currentRegion {
        case .success(let region):
            currentRegionCode = region
        case .failure:
            updateAvailable.state = .ready(.versionUpdate)
            return false
        default:
            updateAvailable.state = .busy(.connecting)
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
