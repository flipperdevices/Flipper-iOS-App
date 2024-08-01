public protocol CatalogService {
    func featured() -> FeaturedRequest

    func categories() -> CategoriesRequest
    func category(_ id: String) -> CategoryRequest

    func applications() -> ApplicationsRequest
    func application(uid: String) -> ApplicationRequest

    func build(forVersionID: String) -> BuildRequest

    func report(uid: String, description: String) async throws
}

public enum SortBy: String, Encodable {
    case updated = "updated_at"
    case created = "created_at"
}

public enum SortOrder: Int, Encodable {
    case asc = 1
    case desc = -1
}
