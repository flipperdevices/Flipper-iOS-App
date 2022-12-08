import Inject
import Peripheral

import Logging
import Combine
import Foundation

@MainActor
public class UpdateService: ObservableObject {
    private let logger = Logger(label: "update-service")

    let appState: AppState
    let flipperService: FlipperService

    private var updateTaskHandle: Task<Void, Swift.Error>?

    public init(appState: AppState, flipperService: FlipperService) {
        self.appState = appState
        self.flipperService = flipperService
    }

    public func cancel() {
        updateTaskHandle?.cancel()
    }

    public func update(
        firmware: Update.Manifest.Version?,
        isProvisioningDisabled: Bool,
        onSuccess: @escaping @MainActor () -> Void,
        onFailure: @escaping @MainActor (Update.State.Error) -> Void
    ) {
        appState.update.state = .update(.preparing)
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
                let archive = try await downloadFirmware(firmware)
                try await flipperService.showUpdatingFrame()
                appState.update.state = .update(.preparing)
                try await flipperService.provideSubGHzRegion()
                let path = try await uploadFirmware(archive)
                try await startUpdateProcess(path)
                onSuccess()
            } catch where error is URLError {
                logger.error("no internet")
                onFailure(.failedDownloading)
                appState.update.state = .error(.noInternet)
            } catch where error is Provisioning.Error {
                logger.error("provisioning: \(error)")
                onFailure(.failedPreparing)
                appState.update.state = .error(.outdatedApp)
            } catch let error as Peripheral.Error
                where error == .storage(.internal) {
                logger.error("update: \(error)")
                onFailure(.failedUploading)
                appState.update.state = .error(.storageError)
            } catch {
                logger.error("update: \(error)")
                onFailure(.failedUploading)
                appState.update.state = .error(.noDevice)
            }
            try? await flipperService.hideUpdatingFrame()
            updateTaskHandle?.cancel()
            updateTaskHandle = nil
        }
    }

    private func downloadFirmware(
        _ firmware: Update.Manifest.Version
    ) async throws -> Update.Firmware {
        appState.update.state = .update(.downloading(progress: 0))
        return try await appState.update.downloadFirmware(firmware) { progress in
            Task { @MainActor in
                if case .update(.downloading) = self.appState.update.state {
                    self.appState.update.state = .update(.downloading(progress: progress))
                }
            }
        }
    }

    private func uploadFirmware(
        _ firmware: Update.Firmware
    ) async throws -> Peripheral.Path {
        appState.update.state = .update(.preparing)
        return try await appState.update.uploadFirmware(firmware) { progress in
            Task { @MainActor in
                if case .update = self.appState.update.state {
                    self.appState.update.state = .update(.uploading(progress: progress))
                }
            }
        }
    }

    private func startUpdateProcess(_ directory: Peripheral.Path) async throws {
        appState.update.state = .update(.preparing)
        try await flipperService.startUpdateProcess(from: directory)
        appState.update.state = .update(.started)
        appState.onUpdateStarted()
    }
}
