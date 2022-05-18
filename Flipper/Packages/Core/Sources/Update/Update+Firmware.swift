import Peripheral
import Foundation

extension Update {
    // swiftlint:disable nesting
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
        guard
            let urlString = version.updateArchive?.url,
            let url = URL(string: urlString)
        else {
            logger.error("invalid firmware url")
            throw Error.invalidFirmwareURL
        }
        logger.info("downloading firmware \(url)")
        let data = URLSessionData(from: url) {
            progress($0.fractionCompleted)
        }
        let entries = try await unpackFirmware(data.bytes)
        return .init(version: version, entries: entries)
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
