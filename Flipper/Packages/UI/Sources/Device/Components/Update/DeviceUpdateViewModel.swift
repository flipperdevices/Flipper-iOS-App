import Core
import Inject
import Combine
import Peripheral
import Foundation
import SwiftUI

@MainActor
class DeviceUpdateViewModel: ObservableObject {
    private let appState: AppState = .shared
    private var disposeBag: DisposeBag = .init()

    @Published var flipper: Flipper? {
        didSet { updateState() }
    }

    var isConnected: Bool {
        flipper?.state == .connected
    }

    let updater = Update()

    enum State {
        case noUpdates
        case versionUpdate
        case channelUpdate
        case downloadingFirmware
        case uploadingFirmware
        case updateInProgress
    }

    @AppStorage("update_channel") var channel: Update.Channel = .development {
        didSet { updateAvailableFirmware() }
    }

    @Published var availableFirmware: String = "" {
        didSet { updateState() }
    }

    @Published var state: State = .noUpdates
    @Published var progress: Int = 0

    var inProgress: Bool {
        state == .downloadingFirmware ||
        state == .uploadingFirmware
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

        updateAvailableFirmware()
    }

    func updateAvailableFirmware() {
        availableFirmware = ""

        Task {
            let manifest = try await updater.downloadManifest()
            guard let version = manifest.version(for: channel) else {
                availableFirmware = "error"
                return
            }
            switch channel {
            case .development:
                availableFirmware = "Dev \(version.version)"
            case .canditate:
                availableFirmware = "RC \(version.version.dropLast(3))"
            case .release:
                availableFirmware = "Release \(version.version)"
            }
        }
    }

    func updateState() {
        state = .noUpdates
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
    }

    func update() {
        state = .downloadingFirmware
        progress = 0

        Task {
            while progress < 100 {
                try await Task.sleep(seconds: 0.005)
                progress += 1
            }
            state = .uploadingFirmware
            progress = 0
            while progress < 100 {
                try await Task.sleep(seconds: 0.05)
                progress += 1
            }
            state = .updateInProgress
            try await Task.sleep(seconds: 1)
            state = .noUpdates
        }
    }

    func cancel() {
    }
}

extension Task where Success == Never, Failure == Never {
    static func sleep(seconds: Double) async throws {
        try await Task.sleep(nanoseconds: UInt64(seconds * 1000 * 1_000_000))
    }
}
