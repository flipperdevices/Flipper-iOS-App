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
    // swiftlint:disable discouraged_optional_boolean
    var noManifest: Bool?

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
    @Published var showPauseSync = false
    @Published var showCharge = false

    @Published var flipper: Flipper? {
        didSet { updateState() }
    }

    var channelSelectorOffset: Double = .zero

    let updater = Update()

    @AppStorage(.updateChannelKey) var channel: Update.Channel = .release

    var manifest: Update.Manifest?
    var availableFirmwareVersion: Update.Manifest.Version?

    @Published var availableFirmware: String = ""
    var availableFirmwareColor: Color {
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

    var lastInstalledFirmware: String = ""

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

    func checkManifest() {
        Task {
            do {
                let size = try await rpc.getSize(at: "/ext/Manifest")
                logger.info("size manifest \(size)")
                noManifest = false
            } catch {
                logger.error("manifest not exist: \(error)")
                noManifest = true
            }
        }
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
            availableFirmware = ""
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

        switch noManifest {
        case .some(true):
            state = .versionUpdate
        case .some(false):
            state = .noUpdates
        default:
            state = .connecting
        }
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

    func validateAvailableFirmware() -> Bool {
        !availableFirmware.isEmpty
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
        guard
            lastInstalledFirmware != installedFirmware,
            installedFirmware == availableFirmware
        else {
            lastInstalledFirmware = installedFirmware
            state = .versionUpdate
            return false
        }
        return true
    }

    // MARK: Confirm update

    func confirmUpdate() {
        guard let battery = flipper?.battery else { return }

        guard battery.level >= 10 || battery.state == .charging else {
            withoutAnimation {
                showCharge = true
            }
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

    func onSuccess() {
        state = .updateInProgress
    }
}
