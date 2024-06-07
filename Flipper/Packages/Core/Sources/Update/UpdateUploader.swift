import Peripheral

public class FirmwareUploader {
    private var storage: StorageAPI

    init(storage: StorageAPI) {
        self.storage = storage
    }

    public func upload(
        _ bundle: UpdateBundle,
        progress: @escaping (Double) -> Void
    ) async throws -> Path {
        guard case let .directory(directory) = bundle.entries.first else {
            throw Update.Error.invalidFirmware
        }
        let bundlePath = Path.update.appending(directory)
        try? await storage.createDirectory(at: .update)
        try? await storage.createDirectory(at: bundlePath)

        let files = await filterExisting(bundle.files, at: .update)

        if !files.isEmpty {
            progress(0)
            try await uploadFiles(files, at: .update, progress: progress)
        }

        return bundlePath
    }

    private func uploadFiles(
        _ files: [UpdateBundle.File],
        at path: Path,
        progress: (Double) -> Void
    ) async throws {
        let totalSize = files.reduce(0) { $0 + $1.data.count }
        var totalSent = 0

        for file in files {
            let bytes = file.data
            let path = path.appending(file.name)
            for try await sent in await storage.write(at: path, bytes: bytes) {
                totalSent += sent
                progress(Double(totalSent) / Double(totalSize))
            }
        }
    }

    private func filterExisting(
        _ files: [UpdateBundle.File],
        at path: Path
    ) async -> [UpdateBundle.File] {
        var result = [UpdateBundle.File]()
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
        try? await storage.hash(of: path)
    }
}
