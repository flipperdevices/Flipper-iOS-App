import Core
import Inject
import Peripheral
import Foundation
import SwiftUI
import Logging

@MainActor
class DeviceUpdateViewModel: ObservableObject {
    private let logger = Logger(label: "update-vm")

    @Inject private var appState: AppState
    private var disposeBag: DisposeBag = .init()

    @Inject private var rpc: RPC

    @Binding var isPresented: Bool
    @Published var deviceStatus: DeviceStatus = .noDevice
    @Published var showCancelUpdate = false

    @AppStorage(.isProvisioningDisabled) var isProvisioningDisabled = false

    var deviceColor: FlipperColor {
        appState.flipper?.color ?? .white
    }

    let updater = Update()

    enum State {
        case downloadingFirmware
        case preparingForUpdate
        case uploadingFirmware
        case canceling
        case noInternet
        case noDevice
        case noCard
        case storageError
        case outdatedAppVersion
    }

    let channel: Update.Channel
    let firmware: Update.Manifest.Version?
    let onSuccess: @MainActor () -> Void
    let onFailure: @MainActor (UpdateError) -> Void

    enum UpdateError {
        case canceled
        case failedDownloading
        case failedPreparing
        case failedUploading
    }

    var availableFirmware: String {
        guard let firmware = firmware else { return "" }
        switch channel {
        case .development: return "Dev \(firmware.version)"
        case .candidate: return "RC \(firmware.version.dropLast(3))"
        case .release: return "Release \(firmware.version)"
        case .custom(let url): return "Custom \(url.lastPathComponent)"
        }
    }

    lazy var changelog: String = {
        return (firmware?.changelog ?? "")
            .replacingPullRequestURLs
            .replacingCompareURLs
            .replacingURLs
    }()

    var availableFirmwareColor: Color {
        switch channel {
        case .development: return .development
        case .candidate: return .candidate
        case .release: return .release
        case .custom: return .custom
        }
    }

    @Published var state: State = .downloadingFirmware
    @Published var progress: Double = 0

    var isUpdating: Bool {
        switch state {
        case .downloadingFirmware, .preparingForUpdate, .uploadingFirmware:
            return true
        default:
            return false
        }
    }

    init(
        isPresented: Binding<Bool>,
        channel: Update.Channel,
        firmware: Update.Manifest.Version?,
        onSuccess: @escaping @MainActor () -> Void,
        onFailure: @escaping @MainActor (UpdateError) -> Void
    ) {
        self._isPresented = isPresented
        self.channel = channel
        self.firmware = firmware
        self.onSuccess = onSuccess
        self.onFailure = onFailure

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
            } catch where error is URLError {
                logger.error("no internet")
                onFailure(.failedDownloading)
                self.state = .noInternet
            } catch where error is Provisioning.Error {
                logger.error("provisioning: \(error)")
                onFailure(.failedPreparing)
                self.state = .outdatedAppVersion
            } catch let error as Peripheral.Error
                where error == .storage(.internal) {
                logger.error("update: \(error)")
                onFailure(.failedUploading)
                self.state = .storageError
            } catch {
                logger.error("update: \(error)")
                onFailure(.failedUploading)
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

    var hardwareRegion: Int? {
        get async throws {
            let info = try await rpc.deviceInfo()
            return Int(info["hardware_region"] ?? "")
        }
    }

    var canDisableProvisioning: Bool {
        get async {
            (try? await hardwareRegion) == 0
        }
    }

    var shouldProvideRegion: Bool {
        get async throws {
            if isProvisioningDisabled, await canDisableProvisioning {
                return false
            } else {
                return true
            }
        }
    }

    func provideSubGHzRegion() async throws {
        state = .preparingForUpdate
        guard try await shouldProvideRegion else {
            return
        }
        try await rpc.writeFile(
            at: Provisioning.location,
            bytes: Provisioning().provideRegion().encode())
    }

    func uploadFirmware(
        _ firmware: Update.Firmware
    ) async throws -> Peripheral.Path {
        state = .preparingForUpdate
        progress = 0
        return try await updater.uploadFirmware(firmware) { progress in
            DispatchQueue.main.async {
                if self.state == .preparingForUpdate {
                    self.state = .uploadingFirmware
                }
                self.progress = progress
            }
        }
    }

    func startUpdateProcess(_ directory: Peripheral.Path) async throws {
        try await updater.startUpdateProcess(from: directory)
        appState.onUpdateStarted()
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
        onFailure(.canceled)
        close()
    }

    func close() {
        isPresented = false
    }

    func readMore() {
        UIApplication.shared.open(.helpToReboot)
    }

    func howToFactoryReset() {
        UIApplication.shared.open(.helpToFactoryReset)
    }
}

private extension String {

    // (^| ) - is simple guard against matching valid markdown link

    var replacingPullRequestURLs: String {
        replacingOccurrences(
            of: #"(^| )(https://github.com/[^\s]+/pull/([0-9]+))"#,
            with: "$1[#$3]($2)",
            options: [.regularExpression])
    }

    var replacingCompareURLs: String {
        replacingOccurrences(
            of: #"(^| )(https://github.com/[^\s]+/compare/([^\s]+))"#,
            with: "$1[$3]($2)",
            options: [.regularExpression])
    }

    var replacingURLs: String {
        replacingOccurrences(
            of: #"(^| )(https://[^\s]+)"#,
            with: "$1[$2]($2)",
            options: [.regularExpression])
    }
}
