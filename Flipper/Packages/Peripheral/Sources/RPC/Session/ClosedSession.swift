public class ClosedSession: Session, RPC {
    public static let shared: ClosedSession = .init()

    enum Error: Swift.Error {
        case closed
    }

    public var onScreenFrame: ((ScreenFrame) -> Void)?
    public var onAppStateChanged: ((Message.AppState) -> Void)?

    public func send(_ message: Message) async throws {
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
