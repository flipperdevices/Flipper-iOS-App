import Foundation

public protocol Session: AnyObject {
    var bytesSent: Int { get }

    var onMessage: ((Message) -> Void)? { get set }
    var onError: ((Error) -> Void)? { get set }

    func send(_ message: Message) async throws
    func send(_ request: Request) async throws -> Response

    func close()
}
