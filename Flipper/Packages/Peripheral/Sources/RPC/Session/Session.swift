import Foundation

public protocol Session: AnyObject {
    var message: AsyncStream<IncomingMessage> { get }

    func send(_ message: OutgoingMessage) async throws
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
