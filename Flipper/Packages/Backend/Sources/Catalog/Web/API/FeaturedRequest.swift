import Backend
import Foundation

public struct FeaturedRequest: BackendRequest {
    public typealias Result = [Application]

    public var path: String { "0/application/featured" }
    public var queryItems: [URLQueryItem] = []

    public let baseURL: URL

    public init(baseURL: URL) {
        self.baseURL = baseURL
    }

    public func skip(_ count: Int) -> Self {
        setQueryItem(name: "offset", value: count)
    }

    public func take(_ count: Int) -> Self {
        setQueryItem(name: "limit", value: count)
    }
}
