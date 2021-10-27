import Foundation

protocol Session {
    func sendRequest(
        _ request: Request,
        continuation: @escaping Continuation,
        consumer: @escaping (Data) -> Void
    )

    func didReceiveData(_ data: Data)
}
