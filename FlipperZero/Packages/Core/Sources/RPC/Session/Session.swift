import Foundation

public enum Priority {
    case background
}

protocol Session: AnyObject {
    var onScreenFrame: ((ScreenFrame) -> Void)? { get set }

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
}
