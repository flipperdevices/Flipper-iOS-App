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

    @Binding var isPresented: Bool
    @Published var deviceStatus: DeviceStatus = .noDevice
    @Published var showCancelUpdate = false

    var deviceColor: FlipperColor {
        appState.flipper?.color ?? .white
    }

    let updater = Update()

    enum State {
        case downloadingFirmware
        case prepearingForUpdate
        case uploadingFirmware
        case canceling
        case noInternet
        case noDevice
        case noCard
    }

    let channel: Update.Channel
    let firmware: Update.Manifest.Version?
    let onSuccess: @MainActor () -> Void

    var availableFirmware: String {
        guard let firmware = firmware else { return "" }
        switch channel {
        case .development: return "Dev \(firmware.version)"
        case .canditate: return "RC \(firmware.version.dropLast(3))"
        case .release: return "Release \(firmware.version)"
        case .custom(let url): return "Custom \(url.lastPathComponent)"
        }
    }

    var changelog: String {
        guard let firmware = firmware else { return "" }
        return firmware.changelog
    }

    var availableFirmwareColor: Color {
        switch channel {
        case .development: return .development
        case .canditate: return .candidate
        case .release: return .release
        case .custom: return .custom
        }
    }

    @Published var state: State = .downloadingFirmware
    @Published var progress: Double = 0

    init(
        isPresented: Binding<Bool>,
        channel: Update.Channel,
        firmware: Update.Manifest.Version?,
        onSuccess: @escaping @MainActor () -> Void
    ) {
        self._isPresented = isPresented
        self.channel = channel
        self.firmware = firmware
        self.onSuccess = onSuccess

        appState.$status
            .receive(on: DispatchQueue.main)
            .assign(to: \.deviceStatus, on: self)
            .store(in: &disposeBag)
    }

    var updateTaskHandle: Task<Void, Swift.Error>?

    func update() {
        guard updateTaskHandle == nil else {
            logger.error("update in progress")
            return
        }
        guard let firmware = firmware else {
            logger.error("invalid firmware")
            return
        }
        updateTaskHandle = Task {
            do {
                let archive = try await downloadFirmware(firmware)
                try await updater.showUpdatingFrame()
                try await provideSubGHzRegion()
                let path = try await uploadFirmware(archive)
                try await startUpdateProcess(path)
                appState.onUpdateStarted()
            } catch where error is URLError {
                logger.error("no internet")
                self.state = .noInternet
            } catch {
                logger.error("update: \(error)")
                self.state = .noDevice
            }
            try? await updater.hideUpdatingFrame()
            updateTaskHandle?.cancel()
            updateTaskHandle = nil
        }
    }

    func downloadFirmware(
        _ firmware: Update.Manifest.Version
    ) async throws -> Update.Firmware {
        state = .downloadingFirmware
        progress = 0
        return try await updater.downloadFirmware(firmware) { progress in
            DispatchQueue.main.async {
                self.progress = progress
            }
        }
    }

    func provideSubGHzRegion() async throws {
        state = .prepearingForUpdate
        let info = try await rpc.deviceInfo()
        guard
            let regionString = info["hardware_region"],
            let region = Int(regionString),
            region >= 0
        else {
            return
        }
        try await rpc.writeFile(
            at: Path(string: Provisioning.location),
            bytes: Provisioning.generate())
    }

    func uploadFirmware(
        _ firmware: Update.Firmware
    ) async throws -> Peripheral.Path {
        state = .prepearingForUpdate
        progress = 0
        return try await updater.uploadFirmware(firmware) { progress in
            DispatchQueue.main.async {
                if self.state == .prepearingForUpdate {
                    self.state = .uploadingFirmware
                }
                self.progress = progress
            }
        }
    }

    func startUpdateProcess(_ directory: Peripheral.Path) async throws {
        try await updater.startUpdateProcess(from: directory)
        onSuccess()
        isPresented = false
    }

    func confirmCancel() {
        showCancelUpdate = true
    }

    func cancel() {
        updateTaskHandle?.cancel()
        appState.disconnect()
        appState.connect()
        isPresented = false
    }

    func readMore() {
        if let url = URL(string: "https://docs.flipperzero.one/basics/reboot") {
            UIApplication.shared.open(url)
        }
    }
}
