import Inject
import Peripheral

import Logging
import Combine
import Foundation

// TODO: Refactor (ex DeviceUpdateModel)

@MainActor
public class DeviceUpdateRefactoring: ObservableObject {
    private let logger = Logger(label: "update-vm")

    @Inject private var appState: AppState
    @Inject private var rpc: RPC
    private var disposeBag: DisposeBag = .init()

    private let updater = Update()

    @Published public var state: State = .loading

    private var updateTaskHandle: Task<Void, Swift.Error>?

    public enum State: Equatable {
        case loading
        case idle(Idle)
        case update(Update)
        case error(Error)

        public enum Idle: Equatable {
            case noUpdates
            case versionUpdate
            case channelUpdate
        }

        public enum Update: Equatable {
            case preparing
            case downloading(progress: Double)
            case uploading(progress: Double)
            case started
            case canceling
        }

        public enum Error: Equatable {
            case noInternet
            case noDevice
            case noCard
            case storageError
            case failedDownloading
            case failedPreparing
            case failedUploading
            case outdatedApp
            case canceled
        }
    }

    public init() {}

    public func update(
        firmware: Update.Manifest.Version?,
        isProvisioningDisabled: Bool,
        onSuccess: @escaping @MainActor () -> Void,
        onFailure: @escaping @MainActor (State.Error) -> Void
    ) {
        state = .update(.preparing)
        guard updateTaskHandle == nil else {
            logger.error("update in progress")
            return
        }
        guard let firmware = firmware else {
            logger.error("invalid firmware")
            return
        }
        // swiftlint:disable closure_body_length
        updateTaskHandle = Task {
            do {
                try await update(
                    firmware: firmware,
                    isProvisioningDisabled: isProvisioningDisabled)
                onSuccess()
            } catch where error is URLError {
                logger.error("no internet")
                onFailure(.failedDownloading)
                self.state = .error(.noInternet)
            } catch where error is Provisioning.Error {
                logger.error("provisioning: \(error)")
                onFailure(.failedPreparing)
                self.state = .error(.outdatedApp)
            } catch let error as Peripheral.Error
                where error == .storage(.internal) {
                logger.error("update: \(error)")
                onFailure(.failedUploading)
                self.state = .error(.storageError)
            } catch {
                logger.error("update: \(error)")
                onFailure(.failedUploading)
                self.state = .error(.noDevice)
            }
            try? await updater.hideUpdatingFrame()
            updateTaskHandle?.cancel()
            updateTaskHandle = nil
        }
    }

    func update(
        firmware: Update.Manifest.Version,
        isProvisioningDisabled: Bool
    ) async throws {
        let archive = try await downloadFirmware(firmware)
        try await updater.showUpdatingFrame()
        state = .update(.preparing)
        try await provideSubGHzRegion(isProvisioningDisabled)
        let path = try await uploadFirmware(archive)
        try await startUpdateProcess(path)
    }

    func downloadFirmware(
        _ firmware: Update.Manifest.Version
    ) async throws -> Update.Firmware {
        state = .update(.downloading(progress: 0))
        return try await updater.downloadFirmware(firmware) { progress in
            Task { @MainActor in
                if case .update(.downloading) = self.state {
                    self.state = .update(.downloading(progress: progress))
                }
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

    func provideSubGHzRegion(_ isProvisioningDisabled: Bool) async throws {
        if isProvisioningDisabled, await canDisableProvisioning {
            return
        }
        try await rpc.writeFile(
            at: Provisioning.location,
            bytes: Provisioning().provideRegion().encode())
    }

    func uploadFirmware(
        _ firmware: Update.Firmware
    ) async throws -> Peripheral.Path {
        state = .update(.preparing)
        return try await updater.uploadFirmware(firmware) { progress in
            Task { @MainActor in
                if case .update = self.state {
                    self.state = .update(.uploading(progress: progress))
                }
            }
        }
    }

    func startUpdateProcess(_ directory: Peripheral.Path) async throws {
        state = .update(.preparing)
        try await updater.startUpdateProcess(from: directory)
        state = .update(.started)
        appState.onUpdateStarted()
    }

    public func cancel() async throws {
        try await updater.hideUpdatingFrame()
        updateTaskHandle?.cancel()
    }
}
