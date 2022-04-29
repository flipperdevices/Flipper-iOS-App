import Inject
import Peripheral
import DCompression
import Foundation
import Logging

public class Update {
    private let logger = Logger(label: "update")

    @Inject var rpc: RPC

    public enum Channel: String {
        case development
        case canditate
        case release
    }

    var manifestURL: URL {
        .init(string: "https://update.flipperzero.one/firmware/directory.json")
        .unsafelyUnwrapped
    }

    public enum Error: Swift.Error {
        case invalidFirmware
        case invalidFirmwareURL
    }

    public init() {
    }

    public func downloadManifest(
        progress: @escaping (Double) -> Void = { _ in }
    ) async throws -> Manifest {
        let data = URLSessionData(from: manifestURL) {
            progress($0.fractionCompleted)
        }
        return try await JSONDecoder()
            .decode(Manifest.self, from: data.result)
    }

    public func downloadFirmware(
        _ version: Update.Manifest.Version,
        progress: @escaping (Double) -> Void
    ) async throws -> [UInt8] {
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
        return try await data.bytes
    }

    public func showUpdatingFrame() async throws {
        try await rpc.startVirtualDisplay(with: updatingFrame)
    }

    public func hideUpdatingFrame() async throws {
        try await rpc.stopVirtualDisplay()
    }

    public func uploadFirmware(
        _ bytes: [UInt8],
        progress: @escaping (Double) -> Void
    ) async throws -> String {
        let entries = try await TAR.decode(from: bytes, compression: .gzip)
        // directory + at least one file
        guard entries.count > 1, entries[0].typeflag == .directory else {
            throw Error.invalidFirmware
        }
        let basePath = "/ext/update"
        let updatePath = "\(basePath)/\(entries[0].name)"
        try? await rpc.createDirectory(at: "\(basePath)")
        try? await rpc.createDirectory(at: "\(updatePath)")

        var files = entries.filter { $0.typeflag == .file }

        files = await filterExising(files, at: basePath)
        progressHack(files: files, progress: progress)

        for file in files {
            let path = Path("\(basePath)/\(file.name)")
            try await rpc.writeFile(at: path, bytes: file.data)
        }

        return updatePath
    }

    public func installFirmware(_ path: String) async throws {
        try await rpc.update(manifest: path + "update.fuf")
        try await rpc.reboot(to: .update)
    }

    // TODO: Refactor

    private func filterExising(
        _ files: [TAR.Entry],
        at path: String
    ) async -> [TAR.Entry] {
        var result = [TAR.Entry]()
        for file in files {
            let path = Path("\(path)/\(file.name)")
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

    private func progressHack(
        files: [TAR.Entry],
        progress: @escaping (Double) -> Void
    ) {
        guard let session = rpc.session else {
            return
        }
        let filesByteCount = files.map { $0.data.count }.reduce(0, +)
        let totalBytes = session.bytesSent + Int(Double(filesByteCount) * 1.185)
        Task {
            while session.bytesSent < totalBytes {
                try await Task.sleep(nanoseconds: 100 * 1_000_000)
                progress(Double(session.bytesSent) / Double(totalBytes))
            }
        }
    }
}
