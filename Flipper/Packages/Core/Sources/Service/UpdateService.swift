import Analytics
import Peripheral

import Combine
import Foundation

@MainActor
public class UpdateService: ObservableObject {
    @Published public var state: State = .update(.preparing)

    public var inProgress: Update.Intent?

    public enum State: Equatable {
        case update(Update)
        case error(Error)

        public enum Update: Equatable {
            case preparing
            case downloading(progress: Double)
            case uploading(progress: Double)
            case started
            case canceling
        }

        public enum Error: Equatable {
            case cantConnect
            case noInternet
            case noDevice
            case noCard
            case storageError
            case outdatedApp
            case failedDownloading
            case failedPreparing
            case failedUploading
            case canceled
        }
    }

    public enum Result {
        case success
        case failure
    }

    private var pairedDevice: PairedDevice
    private var rpc: RPC { pairedDevice.session }

    // next step
    let device: Device

    private var updateTaskHandle: Task<Void, Swift.Error>?

    public init(pairedDevice: PairedDevice, device: Device) {
        self.pairedDevice = pairedDevice
        self.device = device
    }

    public func cancel() {
        updateTaskHandle?.cancel()
        Task {
            device.disconnect()
            try await Task.sleep(milliseconds: 100)
            device.connect()
        }
    }

    public func start(_ intent: Update.Intent) {
        process(intent: intent)
    }

    private func process(intent: Update.Intent) {
        recordUpdateStarted(intent: intent)
        state = .update(.preparing)
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
                if case .error(let error) = state {
                    recordUpdateFailed(intent: intent, error: error)
                }
                logger.error("update: \(error)")
            }
            try? await device.hideUpdatingFrame()
            updateTaskHandle?.cancel()
            updateTaskHandle = nil
        }
    }

    private func prepareForUpdate() async throws {
        state = .update(.preparing)
        do {
            try await device.showUpdatingFrame()
        } catch {
            state = .error(.failedPreparing)
            throw error
        }
    }

    private func provideRegion() async throws {
        do {
            try await device.provideSubGHzRegion()
        } catch let error as Peripheral.Error
            where error == .storage(.internal) {
            logger.error("provide region: \(error)")
            state = .error(.storageError)
            throw error
        }
    }

    private func downloadFirmware(
        _ intent: Update.Intent
    ) async throws -> Update.Firmware {
        do {
            state = .update(.downloading(progress: 0))
            return try await downloadFirmware(intent.to.firmware) { progress in
                Task { @MainActor in
                    if case .update(.downloading) = self.state {
                        self.state = .update(
                            .downloading(progress: progress)
                        )
                    }
                }
            }
        } catch where error is URLError {
            state = .error(.failedDownloading)
            recordUpdateFailed(intent: intent, error: .failedDownloading)
            logger.error("download firmware: \(error.localizedDescription)")
            throw error
        }
    }

    private func uploadFirmware(
        _ firmware: Update.Firmware
    ) async throws -> Peripheral.Path {
        do {
            state = .update(.preparing)
            return try await uploadFirmware(firmware) { progress in
                Task { @MainActor in
                    if case .update = self.state {
                        self.state = .update(
                            .uploading(progress: progress)
                        )
                    }
                }
            }
        } catch let error as Peripheral.Error
            where error == .storage(.internal) {
            state = .error(.storageError)
            logger.error("upload firmware: \(error)")
            throw error
        }
    }

    private func startUpdateProcess(_ directory: Peripheral.Path) async throws {
        state = .update(.preparing)
        try await device.startUpdateProcess(from: directory)
        state = .update(.started)
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
        error: State.Error
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

extension UpdateService {
    public func downloadFirmware(
        _ version: Update.Manifest.Version,
        progress: @escaping (Double) -> Void
    ) async throws -> Update.Firmware {
        guard let url = version.f7UpdateBundle?.url else {
            throw Update.Error.invalidFirmwareURL
        }

        let bytes = url.isFileURL
            ? try await readCustomFirmwareData(url, progress: progress)
            : try await downloadFirmwareData(url, progress: progress)

        let entries = try await [Update.Firmware.Entry](unpacking: bytes)
        return .init(version: version, entries: entries)
    }

    func downloadFirmwareData(
        _ url: URL,
        progress: @escaping (Double) -> Void
    ) async throws -> [UInt8] {
        logger.info("downloading firmware \(url)")
        return try await URLSessionData(from: url) {
            progress($0.fractionCompleted)
        }.bytes
    }

    func readCustomFirmwareData(
        _ url: URL,
        progress: @escaping (Double) -> Void
    ) async throws -> [UInt8] {
        defer { progress(1.0) }
        switch try? Data(contentsOf: url) {
        case .some: return try await readLocalFirmware(from: url)
        case .none: return try await readCloudFirmware(from: url)
        }
    }

    private func readLocalFirmware(from url: URL) async throws -> [UInt8] {
        logger.debug("reading local firmware file: \(url.lastPathComponent)")
        let data = try Data(contentsOf: url)
        try FileManager.default.removeItem(at: url)
        return .init(data)
    }

    private  func readCloudFirmware(from url: URL) async throws -> [UInt8] {
        logger.debug("reading cloud firmware file: \(url.lastPathComponent)")
        let doc = CloudDocument(fileURL: url)
        guard await doc.open(), let data = doc.data else {
            throw Update.Error.invalidFirmwareCloudDocument
        }
        return .init(data)
    }

    public func uploadFirmware(
        _ firmware: Update.Firmware,
        progress: @escaping (Double) -> Void
    ) async throws -> Path {
        guard case let .directory(directory) = firmware.entries.first else {
            throw Update.Error.invalidFirmware
        }
        let firmwareUpdatePath = Path.update.appending(directory)
        try? await rpc.createDirectory(at: .update)
        try? await rpc.createDirectory(at: firmwareUpdatePath)

        let files = await filterExisting(firmware.files, at: .update)

        if !files.isEmpty {
            progress(0)
            try await uploadFiles(files, at: .update, progress: progress)
        }

        return firmwareUpdatePath
    }

    private func uploadFiles(
        _ files: [Update.Firmware.File],
        at path: Path,
        progress: (Double) -> Void
    ) async throws {
        let totalSize = files.reduce(0) { $0 + $1.data.count }
        var totalSent = 0

        for file in files {
            let path = path.appending(file.name)
            for try await sent in rpc.writeFile(at: path, bytes: file.data) {
                totalSent += sent
                progress(Double(totalSent) / Double(totalSize))
            }
        }
    }

    private func filterExisting(
        _ files: [Update.Firmware.File],
        at path: Path
    ) async -> [Update.Firmware.File] {
        var result = [Update.Firmware.File]()
        for file in files {
            let path = path.appending(file.name)
            if let hash = await hash(for: path), hash.value == file.data.md5 {
                continue
            }
            result.append(file)
        }
        return result
    }

    private func hash(for path: Path) async -> Hash? {
        try? await rpc.calculateFileHash(at: path)
    }
}
