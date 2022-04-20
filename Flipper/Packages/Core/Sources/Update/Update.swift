import Inject
import Peripheral
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
            return []
        }
        guard let firmwareURL = version.updateArchive?.url else {
            logger.error("invalid firmware url")
            return []
        }
        logger.info("downloading firmware \(firmwareURL)")
        return .init(try await makeRequest(firmwareURL, progress: progress))
    }

    public func uploadFirmware(_ bytes: [UInt8]) async throws -> String {
        return "/ext/update/VERSION/update.fuf"
    }

    public func installFirmware(_ path: String) async throws {
        try await rpc.reboot(to: .os)
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
            if let error = error {
                completion(.failure(.urlSessionError(error)))
                return
            }
            guard let data = data else {
                completion(.failure(.emptyResponse))
                return
            }
            completion(.success(data))
            self.handle = nil
        }
        handle = task.progress.observe(\.fractionCompleted) { progress, _ in
            progressCallback(progress.fractionCompleted)
        }
        task.resume()
    }
}
