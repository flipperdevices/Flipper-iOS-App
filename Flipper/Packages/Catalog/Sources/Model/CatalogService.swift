public protocol CatalogService {
    func featured() -> FeaturedRequest

    func categories() -> CategoriesRequest
    func category(_ id: String) -> CategoryRequest

    func applications() -> ApplicationsRequest
    func application(uid: String) -> ApplicationRequest

    func bundle(uid: String, target: String, api: String) -> BundleRequest

    func report(uid: String, description: String) async throws
}

public enum SortBy: String {
    case updated = "updated_at"
    case created = "created_at"
}

public enum SortOrder: Int {
    case asc = 1
    case desc = -1
}
