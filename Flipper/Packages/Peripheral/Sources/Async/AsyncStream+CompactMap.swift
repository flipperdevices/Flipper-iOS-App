public extension AsyncStream {
    func compactMap<Transformed>(
        _ transform: @escaping (Self.Element) async -> Transformed?
    ) -> AsyncStream<Transformed> {
        .init { continuation in
            let task = Task {
                for await element in self {
                    if let transformed = await transform(element) {
                        continuation.yield(transformed)
                    }
                }
                continuation.finish()
            }
            continuation.onTermination = { reason in
                if reason == .cancelled {
                    task.cancel()
                }
            }
        }
    }
}
