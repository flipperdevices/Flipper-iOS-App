import Peripheral

class FirmwareUploader {
    private var pairedDevice: PairedDevice
    private var rpc: RPC { pairedDevice.session }

    init(pairedDevice: PairedDevice) {
        self.pairedDevice = pairedDevice
    }

    public func upload(
        _ bundle: UpdateBundle,
        progress: @escaping (Double) -> Void
    ) async throws -> Path {
        guard case let .directory(directory) = bundle.entries.first else {
            throw Update.Error.invalidFirmware
        }
        let bundlePath = Path.update.appending(directory)
        try? await rpc.createDirectory(at: .update)
        try? await rpc.createDirectory(at: bundlePath)

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
            let path = path.appending(file.name)
            for try await sent in rpc.writeFile(at: path, bytes: file.data) {
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
        try? await rpc.calculateFileHash(at: path)
    }
}
