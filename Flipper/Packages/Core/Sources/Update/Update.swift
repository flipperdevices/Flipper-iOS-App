import Inject
import Peripheral
import Foundation

public class Update {
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
    }

    public init() {
    }

    public func downloadManifest() async throws -> Manifest {
        try await JSONDecoder()
            .decode(Manifest.self, from: makeRequest(manifestURL))
    }

    private func makeRequest(_ url: String) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            makeRequest(url, continuation.resume)
        }
    }

    private func makeRequest(
        _ url: String,
        _ completion: @escaping (Result<Data, Error>) -> Void
    ) {
        URLSession.shared.dataTask(
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
        }.resume()
    }
}
