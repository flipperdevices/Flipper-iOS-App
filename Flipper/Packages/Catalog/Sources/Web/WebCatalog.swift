import Foundation

public class WebCatalog: CatalogService {
    private let baseURL = URL("https://catalog.flipp.dev/api/v0")

    public init() {}

    public func featured() -> FeaturedRequest {
        .init(baseURL: baseURL)
    }

    public func categories() -> CategoriesRequest {
        .init(baseURL: baseURL)
    }

    public func category(_ id: String) -> CategoryRequest {
        .init(baseURL: baseURL, uid: id)
    }

    public func applications() -> ApplicationsRequest {
        .init(baseURL: baseURL)
    }

    public func application(uid: String) -> ApplicationRequest {
        .init(baseURL: baseURL, uid: uid)
    }
}
