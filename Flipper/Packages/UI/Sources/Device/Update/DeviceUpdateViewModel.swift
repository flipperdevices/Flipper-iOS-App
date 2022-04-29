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

    let updater = Update()

    enum State {
        case downloadingFirmware
        case prepearingForUpdate
        case uploadingFirmware
        case canceling
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
        }
    }

    var availableFirmwareColor: Color {
        switch channel {
        case .development: return .development
        case .canditate: return .candidate
        case .release: return .release
        }
    }
    @Published var state: State = .downloadingFirmware
    @Published var progress: Int = 0

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
                try await Task.sleep(seconds: 0.3)
                let archive = try await downloadFirmware(firmware)

                try await Task.sleep(seconds: 0.3)
                try await updater.showUpdatingFrame()
                let path = try await uploadFirmware(archive)

                try await Task.sleep(seconds: 0.3)
                try await startUpdateProcess(path)
            } catch {
                logger.error("update error: \(error)")
                try await updater.hideUpdatingFrame()
                cancel()
            }
            updateTaskHandle = nil
        }
    }

    func downloadFirmware(
        _ firmware: Update.Manifest.Version
    ) async throws -> [UInt8] {
        state = .downloadingFirmware
        progress = 0
        return try await updater.downloadFirmware(firmware) {
            let progress = Int($0 * 100)
            DispatchQueue.main.async {
                withAnimation {
                    self.progress = progress
                }
            }
        }
    }

    func uploadFirmware(_ bytes: [UInt8]) async throws -> String {
        state = .prepearingForUpdate
        progress = 0
        return try await updater.uploadFirmware(bytes) {
            let progress = Int($0 * 100)
            DispatchQueue.main.async {
                if progress > 0 {
                    self.state = .uploadingFirmware
                }
                withAnimation(.easeOut) {
                    self.progress = progress
                }
            }
        }
    }

    func startUpdateProcess(_ directory: String) async throws {
        try await updater.installFirmware(directory)
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
}

extension Task where Success == Never, Failure == Never {
    static func sleep(seconds: Double) async throws {
        try await Task.sleep(nanoseconds: UInt64(seconds * 1000 * 1_000_000))
    }
}
