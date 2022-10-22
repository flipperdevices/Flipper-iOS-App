import Core
import Inject
import Analytics
import Peripheral
import Foundation
import Network
import SwiftUI
import Logging

@MainActor
// swiftlint:disable type_body_length
class DeviceUpdateCardModel: ObservableObject {
    private let logger = Logger(label: "update-vm")

    @Inject var rpc: RPC
    @Inject var analytics: Analytics
    private let appState: AppState = .shared
    private var disposeBag: DisposeBag = .init()

    @Published var state: State = .disconnected

    enum State {
        case noSDCard
        case noInternet
        case disconnected
        case connecting
        case noUpdates
        case versionUpdate
        case channelUpdate
        case updateInProgress
    }

    @Published var showChannelSelector = false
    @Published var showConfirmUpdate = false
    @Published var showUpdateView = false
    @Published var showUpdateFailed = false
    @Published var showUpdateSucceeded = false
    @Published var showPauseSync = false
    @Published var showCharge = false

    @Published var flipper: Flipper? {
        didSet { onFlipperChanged(oldValue) }
    }

    var channelSelectorOffset: Double = .zero

    let updater = Update()

    @AppStorage(.updateChannelKey) var channel: Update.Channel = .release

    var manifest: Update.Manifest?
    var availableFirmwareVersion: Update.Manifest.Version?

    @Published var availableFirmware: String?
    var channelColor: Color {
        switch channel {
        case .development: return .development
        case .candidate: return .candidate
        case .release: return .release
        case .custom: return .custom
        }
    }

    enum LazyResult<Success, Failure> where Failure: Swift.Error {
        case idle
        case working
        case success(Success)
        case failure(Failure)
    }

    var hasManifest: LazyResult<Bool, Swift.Error> = .idle
    var currentRegion: LazyResult<ISOCode, Swift.Error> = .idle
    var provisionedRegion: LazyResult<ISOCode, Swift.Error> = .idle

    var hasSDCard: LazyResult<Bool, Swift.Error> {
        guard let storage = flipper?.storage else { return .working }
        return .success(storage.external != nil)
    }

    var installedChannel: Update.Channel? {
        flipper?.information?.firmwareChannel
    }

    var installedFirmware: String? {
        flipper?.information?.shortSoftwareVersion
    }

    init() {
        appState.$flipper
            .receive(on: DispatchQueue.main)
            .assign(to: \.flipper, on: self)
            .store(in: &disposeBag)

        appState.$customFirmwareURL
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .map { .custom($0) }
            .assign(to: \.channel, on: self)
            .store(in: &disposeBag)

        monitorNetworkStatus()
    }

    func onFlipperChanged(_ oldValue: Flipper?) {
        updateState()

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
                _ = try await rpc.getSize(at: "/ext/Manifest")
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

    var updateID: Int = 0
    var updateFromVersion: String?
    var updateToVersion: String?

    func onUpdateStarted() {
        updateID = Int(Date().timeIntervalSince1970)
        updateFromVersion = installedFirmware
        updateToVersion = availableFirmware

        state = .updateInProgress

        analytics.flipperUpdateStart(
            id: updateID,
            from: updateFromVersion ?? "unknown",
            to: updateToVersion ?? "unknown")
    }

    func onUpdateFailed(_ error: DeviceUpdateViewModel.UpdateError) {
        let result: UpdateResult
        switch error {
        case .canceled: result = .canceled
        case .failedDownloading: result = .failedDownload
        case .failedPreparing: result = .failedPrepare
        case .failedUploading: result = .failedUpload
        }
        analytics.flipperUpdateResult(
            id: updateID,
            from: updateFromVersion ?? "unknown",
            to: updateToVersion ?? "unknown",
            status: result)
    }

    var alertVersion: String = ""

    func verifyUpdateResult() {
        guard
            installedFirmware != nil,
            let updateFromVersion = updateFromVersion,
            let updateToVersion = updateToVersion
        else {
            return
        }
        alertVersion = updateToVersion
        self.updateFromVersion = nil
        self.updateToVersion = nil

        var updateFromToVersion: String {
            "from \(updateFromVersion) to \(updateToVersion)"
        }

        Task {
            // FIXME: ignore GATT cache
            try await Task.sleep(milliseconds: 333)

            if installedFirmware == updateToVersion {
                logger.info("update success: \(updateFromToVersion)")
                showUpdateSucceeded = true

                analytics.flipperUpdateResult(
                    id: updateID,
                    from: updateFromVersion,
                    to: updateToVersion,
                    status: .completed)
            } else {
                logger.info("update error: \(updateFromToVersion)")
                showUpdateFailed = true

                analytics.flipperUpdateResult(
                    id: updateID,
                    from: updateFromVersion,
                    to: updateToVersion,
                    status: .failed)
            }
        }
    }

    func updateStorageInfo() {
        Task { await updateStorageInfo() }
    }

    func updateStorageInfo() async {
        // swiftlint:disable statement_position
        do { try await appState.updateStorageInfo() }
        catch { logger.error("update storage info: \(error)") }
    }

    func monitorNetworkStatus() {
        let monitor = NWPathMonitor()
        var lastStatus: NWPath.Status?
        monitor.pathUpdateHandler = { [weak self] path in
            guard lastStatus != path.status else { return }
            self?.onNetworkStatusChanged(path.status)
            lastStatus = path.status
        }
        monitor.start(queue: .main)
    }

    func onNetworkStatusChanged(_ status: NWPath.Status) {
        if status == .unsatisfied {
            self.state = .noInternet
        } else {
            self.state = .connecting
            self.updateAvailableFirmware()
        }
    }

    func onChannelSelected(_ channel: String) {
        showChannelSelector = false
        switch channel {
        case "Release": self.channel = .release
        case "Release-Candidate": self.channel = .candidate
        case "Development": self.channel = .development
        default: break
        }
        updateVersion()
    }

    func updateAvailableFirmware() {
        Task {
            do {
                manifest = try await updater.downloadManifest()
                updateVersion()
            } catch {
                state = .noInternet
                logger.error("download manifest: \(error)")
            }
        }
    }

    func updateVersion() {
        guard let version = manifest?.version(for: channel) else {
            availableFirmware = nil
            availableFirmwareVersion = nil
            return
        }
        self.availableFirmwareVersion = version
        switch channel {
        case .development: availableFirmware = "Dev \(version.version)"
        case .candidate: availableFirmware = "RC \(version.version.dropLast(3))"
        case .release: availableFirmware = "Release \(version.version)"
        case .custom(let url): availableFirmware = "Custom \(url.lastPathComponent)"
        }
        updateState()
    }

    // Validating

    func updateState() {
        guard validateFlipperState() else { return }
        guard validateSDCard() else { return }

        guard validateAvailableFirmware() else { return }

        guard checkSelectedChannel() else { return }
        guard checkInsalledFirmware() else { return }

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
        availableFirmware != nil
    }

    func checkSelectedChannel() -> Bool {
        guard let installedChannel = installedChannel else {
            return false
        }
        guard installedChannel == channel else {
            state = .channelUpdate
            return false
        }
        return true
    }

    func checkInsalledFirmware() -> Bool {
        guard let installedFirmware = installedFirmware else {
            return false
        }
        guard installedFirmware == availableFirmware else {
            state = .versionUpdate
            return false
        }
        return true
    }

    // MARK: Confirm update

    func confirmUpdate() {
        guard let battery = flipper?.battery else { return }

        guard battery.level >= 10 || battery.state == .charging else {
            showCharge = true
            return
        }
        guard appState.status != .synchronizing else {
            showPauseSync = true
            return
        }
        showConfirmUpdate = true
    }

    func update() {
        Task {
            await updateStorageInfo()
            guard validateSDCard() else {
                return
            }
            showUpdateView = true
        }
    }

    func pauseSync() {
        appState.cancelSync()
    }
}
