import Foundation

public enum Priority {
    case background
}

public protocol Session: AnyObject {
    var bytesSent: Int { get }

    var onMessage: ((Message) -> Void)? { get set }
    var onError: ((Error) -> Void)? { get set }

    func send(
        _ message: Message,
        priority: Priority?
    ) async throws

    func send(
        _ request: Request,
        priority: Priority?
    ) async throws -> Response
}

extension Session {
    func send(
        _ request: Request
    ) async throws -> Response {
        try await send(request, priority: nil)
    }

    func send(
        _ message: Message
    ) async throws {
        try await send(message, priority: nil)
    }
}
