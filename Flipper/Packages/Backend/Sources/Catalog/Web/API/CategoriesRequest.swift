import Backend
import Foundation

public struct CategoriesRequest: BackendRequest {
    public typealias Result = [Category]

    public var path: String { "0/category" }
    public var queryItems: [URLQueryItem] = []

    public let baseURL: URL

    public init(baseURL: URL) {
        self.baseURL = baseURL
    }

    public func take(_ count: Int) -> Self {
        setQueryItem(name: "limit", value: count)
    }

    public func target(_ target: String?) -> Self {
        if let target {
            return setQueryItem(name: "target", value: target)
        } else {
            return self
        }
    }

    public func api(_ api: String?) -> Self {
        if let api {
            return setQueryItem(name: "api", value: api)
        } else {
            return self
        }
    }
}
