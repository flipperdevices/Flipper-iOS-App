import Core
import Inject
import Peripheral
import Foundation
import Network
import SwiftUI
import Logging

@MainActor
class DeviceUpdateCardModel: ObservableObject {
    private let logger = Logger(label: "update-vm")

    @Inject var rpc: RPC
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
    @Published var showUpdateSuccessed = false
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
        case .canditate: return .candidate
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
        }

        verifyUpdateResult()
    }

    func resetState() {
        hasManifest = .idle
    }

    func verifyManifest() {
        guard case .idle = hasManifest else { return }
        hasManifest = .working
        Task {
            do {
                _ = try await rpc.getSize(at: "/ext/Manifest")
                hasManifest = .success(true)
            } catch {
                logger.error("manifest doesn't exist: \(error)")
                hasManifest = .success(false)
            }
        }
    }

    var updateFromVersion: String?
    var updateToVersion: String?

    func onUpdateStarted() {
        updateFromVersion = installedFirmware
        updateToVersion = availableFirmware

        state = .updateInProgress
    }

    var alertVersion: String = ""
    var alertVersionColor: Color = .clear

    func verifyUpdateResult() {
        guard
            installedFirmware != nil,
            let updateFromVersion = updateFromVersion,
            let updateToVersion = updateToVersion
        else {
            return
        }
        alertVersion = updateToVersion
        alertVersionColor = channelColor
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
                showUpdateSuccessed = true
            } else {
                logger.info("update error: \(updateFromToVersion)")
                showUpdateFailed = true
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
        case "Release-Candidate": self.channel = .canditate
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
        case .canditate: availableFirmware = "RC \(version.version.dropLast(3))"
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
