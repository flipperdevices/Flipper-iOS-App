import Foundation

public enum Priority {
    case background
}

protocol Session: AnyObject {
    var onScreenFrame: ((ScreenFrame) -> Void)? { get set }

    func sendScreenFrame(_ frame: ScreenFrame) async throws

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
