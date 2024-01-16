import Foundation

public struct CategoriesRequest: CatalogRequest {
    public typealias Result = [Category]

    var path: String { "0/category" }
    var queryItems: [URLQueryItem] = []

    let baseURL: URL

    init(baseURL: URL) {
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
