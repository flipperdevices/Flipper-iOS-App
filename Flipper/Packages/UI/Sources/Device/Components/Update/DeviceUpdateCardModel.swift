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

    private let appState: AppState = .shared
    private var disposeBag: DisposeBag = .init()

    var channelSelectorOffset: Double = .zero

    @Published var showChannelSelector = false
    @Published var showConfirmUpdate = false
    @Published var showUpdateView = false
    @Published var showPauseSync = false
    @Published var showCharge = false

    @Published var flipper: Flipper? {
        didSet { updateState() }
    }

    let updater = Update()

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

    @AppStorage(.updateChannelKey) var channel: Update.Channel = .release {
        didSet { updateState() }
    }

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
    @Published var state: State = .disconnected

    var noSDCard: Bool {
        // ignore ukwnown state
        guard let storage = flipper?.storage else {
            return false
        }
        return storage.external == nil
    }

    var hasBatteryState: Bool {
        flipper?.hasBatteryPowerState == true
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

    var manifest: Update.Manifest? {
        didSet { updateState() }
    }

    func updateStorageInfo() {
        Task {
            await updateStorageInfo()
        }
    }

    func updateStorageInfo() async {
        do {
            try await appState.updateStorageInfo()
        } catch {
            logger.error("retry sd card")
        }
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
            self.state = .noUpdates
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
    }

    func updateAvailableFirmware() {
        Task {
            do {
                manifest = try await updater.downloadManifest()
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
    }

    func updateState() {
        guard
            flipper?.state != .disconnected,
            flipper?.state != .pairingFailed,
            flipper?.state != .invalidPairing
        else {
            if state != .updateInProgress {
                state = .disconnected
            }
            return
        }
        guard flipper?.state == .connected else {
            if state != .noInternet, state != .updateInProgress {
                state = .connecting
            }
            return
        }
        guard !noSDCard else {
            state = .noSDCard
            return
        }
        updateVersion()
        guard
            !availableFirmware.isEmpty,
            let installedFirmware = installedFirmware,
            let installedChannel = installedChannel
        else {
            return
        }
        guard installedChannel == channel else {
            state = .channelUpdate
            return
        }
        guard
            lastInstalledFirmware != installedFirmware,
            installedFirmware == availableFirmware
        else {
            lastInstalledFirmware = installedFirmware
            state = .versionUpdate
            return
        }
        state = .noUpdates
    }

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
            guard !noSDCard else {
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
