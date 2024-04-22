public class ClosedSession: Session {
    enum Error: Swift.Error {
        case closed
    }

    var messageStream: BroadcastStream<IncomingMessage> = .init()

    public var message: AsyncStream<IncomingMessage> {
        messageStream.subscribe()
    }

    public init() {
    }

    public func send(_ message: OutgoingMessage) async throws {
        throw Error.closed
    }

    public func send(_ request: Request) async -> AsyncThrowingStreams {
        .init { output, input in
            output.finish(throwing: Error.closed)
            input.finish(throwing: Error.closed)
        }
    }

    public func close() async {
    }
}
