import Foundation

public protocol Session: AnyObject {
    var onMessage: ((Message) -> Void)? { get set }
    var onError: ((Error) -> Void)? { get set }

    func send(_ message: Message) async throws
    func send(_ request: Request) async -> AsyncThrowingStreams

    func close() async
}

extension AsyncThrowingStreams {
    var response: Response {
        get async throws {
            var response: Response?
            for try await next in input {
                switch response {
                case .none:
                    response = next
                case .some(let partial):
                    response = try partial.appending(contentsOf: next)
                }
            }
            guard let response = response else {
                throw Error.unexpectedResponse(nil)
            }
            return response
        }
    }
}
