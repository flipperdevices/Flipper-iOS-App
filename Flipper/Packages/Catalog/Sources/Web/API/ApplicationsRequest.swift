import Foundation

public struct ApplicationsRequest: CatalogRequest {
    public typealias Result = [Application]
    
    var path: String { "application" }
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

    public func filter(_ query: String) -> Self {
        setQueryItem(name: "query", value: query)
    }

    public func category(_ categoryID: String) -> Self {
        setQueryItem(name: "category_id", value: categoryID)
    }

    public func sort(by: SortBy) -> Self {
        setQueryItem(name: "sort_by", value: by)
    }

    public func order(_ order: SortOrder) -> Self {
        setQueryItem(name: "sort_order", value: order)
    }

    public func filter(applicationIDs: [String]) -> Self {
        setQueryItem(name: "applications", value: applicationIDs)
    }

    public func target(_ target: String) -> Self {
        setQueryItem(name: "target", value: target)
    }

    public func api(_ api: String) -> Self {
        setQueryItem(name: "api", value: api)
    }

    public func hasBuild(_ hasBuild: Bool) -> Self {
        setQueryItem(name: "has_version", value: hasBuild)
    }

    public func releaseBuild(_ hasRelease: Bool) -> Self {
        setQueryItem(name: "is_latest_release_version", value: hasRelease)
    }
}
