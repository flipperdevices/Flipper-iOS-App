import Foundation

class URLSessionData {
    let url: URL
    let progress: (Progress) -> Void
    private var handle: NSKeyValueObservation?

    var bytes: [UInt8] {
        get async throws {
            try await .init(result)
        }
    }

    var result: Data {
        get async throws {
            try await makeRequest()
        }
    }

    init(from url: URL, progress: @escaping (Progress) -> Void) {
        self.url = url
        self.progress = progress
    }

    private func makeRequest() async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            makeRequest(continuation.resume)
        }
    }

    private func makeRequest(
        _ completion: @escaping (Result<Data, Swift.Error>) -> Void
    ) {
        guard handle == nil else {
            completion(.failure(URLError(.unknown)))
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            defer { self.handle = nil }
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(URLError(.zeroByteResource)))
                return
            }
            completion(.success(data))
        }
        handle = task.progress.observe(\.fractionCompleted) { progress, _ in
            self.progress(progress)
        }
        task.resume()
    }
}
