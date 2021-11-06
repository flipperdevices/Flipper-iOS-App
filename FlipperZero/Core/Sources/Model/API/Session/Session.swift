import Foundation

public enum Priority {
    case background
}

protocol Session: AnyObject {
    var delegate: PeripheralOutputDelegate? { get set }

    func sendRequest(
        _ request: Request,
        priority: Priority?,
        continuation: @escaping Continuation
    )

    func didReceiveData(_ data: Data)

    func didReceiveFlowControl(_ data: Data)
}

protocol PeripheralOutputDelegate: AnyObject {
    func send(_ data: Data)
}
