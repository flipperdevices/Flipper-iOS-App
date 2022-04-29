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

    var manifestURL: String {
        "https://update.flipperzero.one/firmware/directory.json"
    }

    public enum Error: Swift.Error {
        case urlSessionError(Swift.Error)
        case emptyResponse
        case inProgress
        case invalidFirmware
        case invalidFirmwareURL
    }

    public init() {
    }

    public func downloadManifest() async throws -> Manifest {
        try await JSONDecoder()
            .decode(Manifest.self, from: makeRequest(manifestURL))
    }

    public func downloadFirmware(
        from channel: Update.Channel,
        progress: @escaping (Double) -> Void
    ) async throws -> [UInt8] {
        let manifest = try await downloadManifest()
        guard let version = manifest.version(for: channel) else {
            logger.error("invalid firmware version")
            throw Error.invalidFirmware
        }
        guard let firmwareURL = version.updateArchive?.url else {
            logger.error("invalid firmware url")
            throw Error.invalidFirmwareURL
        }
        logger.info("downloading firmware \(firmwareURL)")
        return .init(try await makeRequest(firmwareURL, progress: progress))
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

    // TODO: Move out

    private func makeRequest(
        _ url: String,
        progress: @escaping (Double) -> Void = { _ in }
    ) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            makeRequest(url, progress, continuation.resume)
        }
    }

    private var handle: NSKeyValueObservation?

    private func makeRequest(
        _ url: String,
        _ progressCallback: @escaping (Double) -> Void,
        _ completion: @escaping (Result<Data, Error>) -> Void
    ) {
        guard handle == nil else {
            logger.error("operation in progress")
            completion(.failure(.inProgress))
            return
        }
        let task = URLSession.shared.dataTask(
            with: URL(string: url).unsafelyUnwrapped
        ) { data, _, error in
            defer { self.handle = nil }
            if let error = error {
                completion(.failure(.urlSessionError(error)))
                return
            }
            guard let data = data else {
                completion(.failure(.emptyResponse))
                return
            }
            completion(.success(data))
        }
        handle = task.progress.observe(\.fractionCompleted) { progress, _ in
            progressCallback(progress.fractionCompleted)
        }
        task.resume()
    }
}
