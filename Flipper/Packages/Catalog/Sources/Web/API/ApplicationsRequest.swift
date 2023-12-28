import Foundation

public struct ApplicationsRequest: CatalogRequest {
    public typealias Result = [ApplicationInfo]

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

    public func category(_ categoryID: String?) -> Self {
        if let categoryID {
            return setQueryItem(name: "category_id", value: categoryID)
        } else {
            return self
        }
    }

    public func uids(_ uids: [String]) -> Self {
        setQueryItem(name: "applications", value: uids)
    }

    public func sort(by sortBy: SortBy) -> Self {
        setQueryItem(name: "sort_by", value: sortBy)
    }

    public func order(_ order: SortOrder) -> Self {
        setQueryItem(name: "sort_order", value: order)
    }

    public func filter(applicationIDs: [String]) -> Self {
        setQueryItem(name: "applications", value: applicationIDs)
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

    public func hasBuild(_ hasBuild: Bool) -> Self {
        setQueryItem(name: "has_version", value: hasBuild)
    }

    public func releaseBuild(_ hasRelease: Bool) -> Self {
        setQueryItem(name: "is_latest_release_version", value: hasRelease)
    }
}
