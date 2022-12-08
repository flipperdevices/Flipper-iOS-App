import Inject
import Analytics
import Peripheral

import Logging
import Combine
import Foundation

// TODO: Refactor (ex DeviceUpdateCardModel)

@MainActor
// swiftlint:disable type_body_length
public class CheckUpdateRefactoring: ObservableObject {
    private let logger = Logger(label: "update-vm")

    @Inject private var rpc: RPC
    @Inject var analytics: Analytics
    @Inject private var appState: AppState
    private var disposeBag: DisposeBag = .init()

    @Published public var state: State = .disconnected

    public enum State {
        case noSDCard
        case noInternet
        case cantConnect
        case disconnected
        case connecting
        case noUpdates
        case versionUpdate
        case channelUpdate
        case updateInProgress
    }

    public var updateResult: PassthroughSubject<UpdateResult, Never> = .init()

    @Published var flipper: Flipper? {
        didSet { onFlipperChanged(oldValue) }
    }

    let update = Update()

    var manifest: Update.Manifest?

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

    var installedChannel: Update.Channel? {
        flipper?.information?.firmwareChannel
    }

    var installedFirmware: String? {
        flipper?.information?.shortSoftwareVersion
    }

    public init() {
        subscribeToPublishers()
    }

    func subscribeToPublishers() {
        appState.$flipper
            .receive(on: DispatchQueue.main)
            .assign(to: \.flipper, on: self)
            .store(in: &disposeBag)
    }

    func onFlipperChanged(_ oldValue: Flipper?) {
        updateState(channel: appState.update.selectedChannel)

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

    public func onUpdateStarted() {
        guard
            let installed = appState.update.installed,
            let available = appState.update.available
        else {
            return
        }

        appState.update.updateInProgress = .init(
            id: Int(Date().timeIntervalSince1970),
            from: installed,
            to: available
        )

        state = .updateInProgress

        analytics.flipperUpdateStart(
            id: appState.update.updateInProgress?.id ?? 0,
            from: appState.update.updateInProgress?.from.version.version ?? "unknown",
            to: appState.update.updateInProgress?.to.version.version ?? "unknown")
    }

    public func onUpdateFailed(_ error: Update.State.Error) {
        let result: UpdateResult
        switch error {
        case .canceled: result = .canceled
        case .failedDownloading: result = .failedDownload
        case .failedPreparing: result = .failedPrepare
        case .failedUploading: result = .failedUpload
        default: result = .failed
        }
        analytics.flipperUpdateResult(
            id: appState.update.updateInProgress?.id ?? 0,
            from: appState.update.updateInProgress?.from.version.version ?? "unknown",
            to: appState.update.updateInProgress?.to.version.version ?? "unknown",
            status: result)
    }

    func verifyUpdateResult() {
        guard
            let installed = appState.update.installed,
            let inProgress = appState.update.updateInProgress
        else {
            return
        }

        var updateFromToVersion: String {
            "from \(inProgress.from.version) to \(inProgress.to.version)"
        }

        Task {
            // FIXME: ignore GATT cache
            try await Task.sleep(milliseconds: 333)

            if installed.version.version == inProgress.to.version.version {
                logger.info("update success: \(updateFromToVersion)")
                updateResult.send(.completed)

                analytics.flipperUpdateResult(
                    id: inProgress.id,
                    from: inProgress.from.version.version,
                    to: inProgress.to.version.version,
                    status: .completed)
            } else {
                logger.info("update error: \(updateFromToVersion)")
                updateResult.send(.failed)

                analytics.flipperUpdateResult(
                    id: inProgress.id,
                    from: inProgress.from.version.version,
                    to: inProgress.to.version.version,
                    status: .failed)
            }
        }
    }

    public func updateStorageInfo() {
        Task { await updateStorageInfo() }
    }

    func updateStorageInfo() async {
        // swiftlint:disable statement_position
        do { try await appState.updateStorageInfo() }
        catch { logger.error("update storage info: \(error)") }
    }

    public func onNetworkStatusChanged(available: Bool) {
        switch available {
        case true: self.state = .connecting
        case false: self.state = .noInternet
        }
    }

    public func updateAvailableFirmware(for channel: Update.Channel) {
        Task {
            do {
                guard state != .noInternet else { return }
                manifest = try await update.downloadManifest()
                updateVersion(for: channel)
            } catch {
                state = .cantConnect
                logger.error("download manifest: \(error)")
            }
        }
    }

    public func updateVersion(for channel: Update.Channel) {
        guard let version = manifest?.version(for: channel) else {
            appState.update.available = nil
            return
        }

        appState.update.available = .init(
            channel: channel,
            version: version)

        updateState(channel: channel)
    }

    // Validating

    func updateState(channel: Update.Channel) {
        guard validateFlipperState() else { return }
        guard validateSDCard() else { return }

        guard validateAvailableFirmware() else { return }

        guard checkSelectedChannel(channel) else { return }
        guard checkInstalledFirmware() else { return }

        guard validateManifest() else { return }
        guard validateRegion() else { return }

        state = .noUpdates
    }

    func validateFlipperState() -> Bool {
        guard let flipper = flipper else { return false }

        switch flipper.state {
        case .connected:
            return true
        case .connecting:
            if state != .noInternet, state != .updateInProgress {
                state = .connecting
            }
            return false
        default:
            if state != .updateInProgress {
                state = .disconnected
            }
            return false
        }
    }

    func validateSDCard() -> Bool {
        guard case .success(let hasSDCard) = hasSDCard else {
            state = .connecting
            return false
        }
        guard hasSDCard else {
            state = .noSDCard
            return false
        }
        return true
    }

    func validateManifest() -> Bool {
        guard case .success(let hasManifest) = hasManifest else {
            state = .connecting
            return false
        }
        guard hasManifest else {
            state = .versionUpdate
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
            state = .versionUpdate
            return false
        default:
            state = .connecting
            return false
        }

        switch currentRegion {
        case .success(let region):
            currentRegionCode = region
        case .failure:
            state = .versionUpdate
            return false
        default:
            state = .connecting
            return false
        }

        guard currentRegionCode == provisionedRegionCode else {
            state = .versionUpdate
            return false
        }

        return true
    }

    func validateAvailableFirmware() -> Bool {
        appState.update.available != nil
    }

    func checkSelectedChannel(_ channel: Update.Channel) -> Bool {
        guard let installedChannel = installedChannel else {
            return false
        }
        guard installedChannel == channel else {
            state = .channelUpdate
            return false
        }
        return true
    }

    func checkInstalledFirmware() -> Bool {
        guard let installedFirmware = installedFirmware else {
            return false
        }
        guard installedFirmware == update.available?.version.version else {
            state = .versionUpdate
            return false
        }
        return true
    }
}
