import Backend
import Foundation

public struct ApplicationsRequest: BackendRequest {
    public typealias Result = [Application]

    public var path: String { "1/application" }
    public var queryItems: [URLQueryItem] = []

    public let baseURL: URL

    struct Params: Encodable {
        var offset: Int?
        var limit: Int?
        var query: String?
        var categoryId: String?
        var applications: [String]?
        var sortBy: SortBy?
        var sortOrder: SortOrder?
        var target: String?
        var api: String?
        var hasVersion: Bool?
        var isLatedtRelease: Bool?

        enum CodingKeys: String, CodingKey {
            case offset
            case limit
            case query
            case categoryId = "category_id"
            case applications
            case sortBy = "sort_by"
            case sortOrder = "sort_order"
            case target
            case api
            case hasVersion = "has_version"
            case isLatedtRelease = "is_latest_release_version"
        }
    }

    var params: Params = .init()

    public var method: String? { "POST" }
    public var body: Encodable? { params }

    init(baseURL: URL) {
        self.baseURL = baseURL
    }

    public func skip(_ count: Int) -> Self {
        modify { params in
            params.offset = count
        }
    }

    public func take(_ count: Int) -> Self {
        modify { params in
            params.limit = count
        }
    }

    public func filter(_ query: String) -> Self {
        modify { params in
            params.query = query
        }
    }

    public func category(_ categoryID: String?) -> Self {
        modify { params in
            params.categoryId = categoryID
        }
    }

    public func uids(_ uids: [String]) -> Self {
        modify { params in
            params.applications = uids
        }
    }

    public func sort(by sortBy: SortBy) -> Self {
        modify { params in
            params.sortBy = sortBy
        }
    }

    public func order(_ order: SortOrder) -> Self {
        modify { params in
            params.sortOrder = order
        }
    }

    public func filter(applicationIDs: [String]) -> Self {
        modify { params in
            params.applications = applicationIDs
        }
    }

    public func target(_ target: String?) -> Self {
        modify { params in
            params.target = target
        }
    }

    public func api(_ api: String?) -> Self {
        modify { params in
            params.api = api
        }
    }

    public func hasBuild(_ hasBuild: Bool) -> Self {
        modify { params in
            params.hasVersion = hasBuild
        }
    }

    public func releaseBuild(_ hasRelease: Bool) -> Self {
        modify { params in
            params.isLatedtRelease = hasRelease
        }
    }
}

extension ApplicationsRequest {
    func modify(_ task: (inout Params) -> Void) -> Self {
        var request = self
        task(&request.params)
        return request
    }
}
