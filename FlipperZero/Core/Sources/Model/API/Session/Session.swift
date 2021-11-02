import Foundation

protocol Session {
    func sendRequest(
        _ request: Request,
        priority: Priority?,
        continuation: @escaping Continuation,
        consumer: @escaping (Data) -> Void
    )

    func didReceiveData(_ data: Data)
}

public enum Priority {
    case background
}
