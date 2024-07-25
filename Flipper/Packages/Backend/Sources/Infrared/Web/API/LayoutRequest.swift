import Backend
import Foundation

public struct LayoutRequest: BackendRequest {
    public typealias Result = InfraredLayout

    public var path: String { "ui" }
    public var queryItems: [URLQueryItem]

    public let baseURL: URL

    public init(baseURL: URL, ifrId: Int) {
        self.baseURL = baseURL
        self.queryItems = [ .init(name: "ifr_file_id", value: ifrId) ]
    }
}
