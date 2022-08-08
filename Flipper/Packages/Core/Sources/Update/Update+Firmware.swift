import Peripheral
import Foundation

extension Update {
    public struct Firmware {
        let version: Manifest.Version
        let entries: [Entry]

        public enum Entry {
            case file(File)
            case directory(String)
        }

        public struct File {
            let name: String
            let data: [UInt8]
        }

        var files: [File] {
            entries.compactMap { entry in
                switch entry {
                case let .file(file): return file
                default: return nil
                }
            }
        }
    }

    public func downloadFirmware(
        _ version: Manifest.Version,
        progress: @escaping (Double) -> Void
    ) async throws -> Firmware {
        guard let url = version.updateArchive?.url else {
            throw Error.invalidFirmwareURL
        }

        let bytes = url.isFileURL
            ? try await readCustomFirmwareData(url, progress: progress)
            : try await downloadFirmwareData(url, progress: progress)

        let entries = try await unpackFirmware(bytes)
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
        let doc = await CloudDocument(fileURL: url)
        guard await doc.open(), let data = await doc.data else {
            throw Error.invalidFirmwareCloudDocument
        }
        return .init(data)
    }

    public func uploadFirmware(
        _ firmware: Firmware,
        progress: @escaping (Double) -> Void
    ) async throws -> Path {
        guard case let .directory(directory) = firmware.entries.first else {
            throw Error.invalidFirmware
        }
        let basePath = Path("/ext/update")
        let updatePath = basePath.appending(directory)
        try? await rpc.createDirectory(at: basePath)
        try? await rpc.createDirectory(at: updatePath)

        let files = await filterExising(firmware.files, at: basePath)

        if !files.isEmpty {
            progress(0)
            try await uploadFiles(files, at: basePath, progress: progress)
        }

        return updatePath
    }

    private func uploadFiles(
        _ files: [Firmware.File],
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

    private func filterExising(
        _ files: [Firmware.File],
        at path: Path
    ) async -> [Firmware.File] {
        var result = [Firmware.File]()
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
