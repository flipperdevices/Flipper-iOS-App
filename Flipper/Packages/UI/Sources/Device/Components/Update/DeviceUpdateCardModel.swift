import Core
import Inject
import Peripheral
import Foundation
import SwiftUI
import Logging

@MainActor
class DeviceUpdateCardModel: ObservableObject {
    private let logger = Logger(label: "update-vm")

    private let appState: AppState = .shared
    private var disposeBag: DisposeBag = .init()

    @Published var showUpdateView = false

    @Published var flipper: Flipper? {
        didSet { updateState() }
    }

    let updater = Update()

    enum State {
        case disconnected
        case connecting
        case noUpdates
        case versionUpdate
        case channelUpdate
        case updateInProgress
    }

    @AppStorage("update_channel") var channel: Update.Channel = .development {
        didSet { updateState() }
    }

    var availableFirmwareVersion: Update.Manifest.Version?

    @Published var availableFirmware: String = ""
    var availableFirmwareColor: Color {
        switch channel {
        case .development: return .development
        case .canditate: return .candidate
        case .release: return .release
        }
    }
    @Published var state: State = .disconnected

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

        updateAvailableFirmware()
    }

    var manifest: Update.Manifest? {
        didSet { updateState() }
    }

    func updateAvailableFirmware() {
        Task {
            self.manifest = try await updater.downloadManifest()
        }
    }

    func updateVersion() {
        guard let version = manifest?.version(for: channel) else {
            availableFirmware = ""
            return
        }
        self.availableFirmwareVersion = version
        switch channel {
        case .development: availableFirmware = "Dev \(version.version)"
        case .canditate: availableFirmware = "RC \(version.version.dropLast(3))"
        case .release: availableFirmware = "Release \(version.version)"
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
            state = .connecting
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

    func update() {
        showUpdateView = true
    }

    func onSuccess() {
        state = .updateInProgress
    }
}
