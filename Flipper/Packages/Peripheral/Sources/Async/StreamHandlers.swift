import Foundation

class BroadcastStream<Element> {
    var consumers: [UUID: AsyncStream<Element>.Continuation] = [:]

    deinit {
        consumers.values.forEach {
            $0.finish()
        }
    }

    func subscribe() -> AsyncStream<Element> {
        .init { continuation in
            let uuid = UUID()
            continuation.onTermination = { [weak self] _ in
                guard let self else { return }
                consumers[uuid] = nil
            }
            consumers[uuid] = continuation
        }
    }

    func yield(_ element: Element) {
        consumers.values.forEach {
            $0.yield(element)
        }
    }
}
