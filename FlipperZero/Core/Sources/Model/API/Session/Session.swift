import Foundation

public enum Priority {
    case background
}

protocol Session: AnyObject {
    var delegate: SessionDelegate? { get set }

    func sendRequest(
        _ request: Request,
        priority: Priority?,
        continuation: @escaping Continuation
    )

    func didReceiveData(_ data: Data)
}

protocol SessionDelegate: AnyObject {
    func send(_ data: Data)
}
