import Foundation

public struct FeaturedRequest: CatalogRequest {
    public typealias Result = [Application]

    var path: String { "application/featured" }
    var queryItems: [URLQueryItem] = []

    let baseURL: URL

    init(baseURL: URL) {
        self.baseURL = baseURL
    }

    public func skip(_ count: Int) -> Self {
        setQueryItem(name: "offset", value: count)
    }

    public func take(_ count: Int) -> Self {
        setQueryItem(name: "limit", value: count)
    }
}
