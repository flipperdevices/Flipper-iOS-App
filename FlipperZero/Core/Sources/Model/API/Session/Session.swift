import Foundation

protocol Session {
    typealias Continuation = (Response) -> Void

    func sendRequest(
        _ request: Request,
        continuation: @escaping Continuation,
        consumer: @escaping (Data) -> Void
    )

    func didReceiveData(_ data: Data)
}
