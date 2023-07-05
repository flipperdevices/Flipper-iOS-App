import Foundation

public struct CategoriesRequest: CatalogRequest {
    public typealias Result = [Category]

    var path: String { "category" }
    var queryItems: [URLQueryItem] = []

    let baseURL: URL

    init(baseURL: URL) {
        self.baseURL = baseURL
    }

    public func take(_ count: Int) -> Self {
        setQueryItem(name: "limit", value: count)
    }

    public func target(_ target: String) -> Self {
        setQueryItem(name: "target", value: target)
    }

    public func api(_ api: String) -> Self {
        setQueryItem(name: "api", value: api)
    }
}
