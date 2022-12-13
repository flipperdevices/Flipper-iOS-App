import Inject
import Analytics
import Peripheral

import Logging
import Combine
import Foundation

@MainActor
public class UpdateService: ObservableObject {
    private let logger = Logger(label: "update-service")

    let appState: AppState
    let flipperService: FlipperService

    var update: Update {
        get { appState.update }
        set { appState.update = newValue }
    }

    @Inject var analytics: Analytics

    private var updateTaskHandle: Task<Void, Swift.Error>?

    public init(appState: AppState, flipperService: FlipperService) {
        self.appState = appState
        self.flipperService = flipperService
    }

    public func cancel() {
        updateTaskHandle?.cancel()
        Task {
            flipperService.disconnect()
            try await Task.sleep(milliseconds: 100)
            flipperService.connect()
        }
    }

    public func start(_ intent: Update.Intent) {
        update.intent = intent
        process(intent: intent)
    }

    public func retry() {
        guard let intent = update.intent else {
            return
        }
        process(intent: intent)
    }

    private func process(intent: Update.Intent) {
        recordUpdateStarted(intent: intent)
        update.state = .update(.preparing)
        guard updateTaskHandle == nil else {
            logger.error("update in progress")
            return
        }
        updateTaskHandle = Task {
            do {
                let archive = try await downloadFirmware(intent)
                try await prepareForUpdate()
                try await provideRegion()
                let path = try await uploadFirmware(archive)
                try await startUpdateProcess(path)
            } catch {
                if case .error(let error) = update.state {
                    recordUpdateFailed(intent: intent, error: error)
                }
                logger.error("update: \(error)")
            }
            try? await flipperService.hideUpdatingFrame()
            updateTaskHandle?.cancel()
            updateTaskHandle = nil
        }
    }

    private func prepareForUpdate() async throws {
        update.state = .update(.preparing)
        do {
            try await flipperService.showUpdatingFrame()
        } catch {
            update.state = .error(.failedPreparing)
            throw error
        }
    }

    private func provideRegion() async throws {
        do {
            try await flipperService.provideSubGHzRegion()
        } catch let error as Peripheral.Error
            where error == .storage(.internal) {
            logger.error("provide region: \(error)")
            update.state = .error(.storageError)
            throw error
        }
    }

    private func downloadFirmware(
        _ intent: Update.Intent
    ) async throws -> Update.Firmware {
        do {
            update.state = .update(.downloading(progress: 0))
            return try await update
                .downloadFirmware(intent.to.firmware) { progress in
                    Task { @MainActor in
                        if case .update(.downloading) = self.update.state {
                            self.update.state = .update(
                                .downloading(progress: progress)
                            )
                        }
                    }
                }
        } catch where error is URLError {
            update.state = .error(.failedDownloading)
            recordUpdateFailed(intent: intent, error: .failedDownloading)
            logger.error("download firmware: \(error.localizedDescription)")
            throw error
        }
    }

    private func uploadFirmware(
        _ firmware: Update.Firmware
    ) async throws -> Peripheral.Path {
        do {
            update.state = .update(.preparing)
            return try await update.uploadFirmware(firmware) { progress in
                Task { @MainActor in
                    if case .update = self.update.state {
                        self.update.state = .update(
                            .uploading(progress: progress)
                        )
                    }
                }
            }
        } catch let error as Peripheral.Error
            where error == .storage(.internal) {
            update.state = .error(.storageError)
            logger.error("upload firmware: \(error)")
            throw error
        }
    }

    private func startUpdateProcess(_ directory: Peripheral.Path) async throws {
        update.state = .update(.preparing)
        try await flipperService.startUpdateProcess(from: directory)
        update.state = .update(.started)
        appState.status = .updating
        logger.info("update started")
    }

    // MARK: Analytics

    func recordUpdateStarted(intent: Update.Intent) {
        analytics.flipperUpdateStart(
            id: intent.id,
            from: intent.from.description,
            to: intent.to.description)
    }

    func recordUpdateFailed(
        intent: Update.Intent,
        error: Update.State.Error
    ) {
        let result: UpdateResult
        switch error {
        case .canceled: result = .canceled
        case .failedDownloading: result = .failedDownload
        case .failedPreparing: result = .failedPrepare
        case .failedUploading: result = .failedUpload
        default: result = .failed
        }
        analytics.flipperUpdateResult(
            id: intent.id,
            from: intent.from.description,
            to: intent.to.description,
            status: result)
    }
}
