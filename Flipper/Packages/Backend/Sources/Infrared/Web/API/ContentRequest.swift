import Backend
import Foundation

public struct ContentRequest: BackendRequest {
    public typealias Result = InfraredKeyContent

    public var path: String { "key" }
    public var queryItems: [URLQueryItem]

    public let baseURL: URL

    public init(baseURL: URL, ifrId: Int) {
        self.baseURL = baseURL
        self.queryItems = [ .init(name: "ifr_file_id", value: ifrId) ]
    }
}
