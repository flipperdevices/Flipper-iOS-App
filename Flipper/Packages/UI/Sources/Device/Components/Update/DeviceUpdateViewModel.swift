import Core
import Inject
import Peripheral
import Foundation
import SwiftUI
import Logging

@MainActor
class DeviceUpdateViewModel: ObservableObject {
    private let logger = Logger(label: "update-vm")

    private let appState: AppState = .shared
    private var disposeBag: DisposeBag = .init()

    @Inject var rpc: RPC

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

    var updateTaskHandle: Task<Void, Swift.Error>?

    func update() {
        guard updateTaskHandle == nil else {
            logger.error("update in progress")
            return
        }
        updateTaskHandle = Task {
            do {
                let archive = try await downloadFirmware()
                let path = try await uploadFirmware(archive)
                try await startUpdateProcess(path)
            } catch {
                logger.error("update error: \(error)")
            }
            updateTaskHandle = nil
        }
    }

    func downloadFirmware() async throws -> [UInt8] {
        state = .downloadingFirmware
        progress = 0
        return try await updater.downloadFirmware(from: channel) {
            let progress = Int($0 * 100)
            DispatchQueue.main.async {
                withAnimation {
                    self.progress = progress
                }
            }
        }
    }

    func uploadFirmware(_ bytes: [UInt8]) async throws -> String {
        state = .uploadingFirmware
        progress = 0
        return try await updater.uploadFirmware(bytes)
    }

    func startUpdateProcess(_ fuf: String) async throws {
        state = .updateInProgress
        progress = 0
        try await updater.installFirmware(fuf)
    }

    func cancel() {
        updateTaskHandle?.cancel()
    }
}

extension Task where Success == Never, Failure == Never {
    static func sleep(seconds: Double) async throws {
        try await Task.sleep(nanoseconds: UInt64(seconds * 1000 * 1_000_000))
    }
}
