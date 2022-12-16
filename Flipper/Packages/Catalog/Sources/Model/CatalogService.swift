public protocol CatalogService {
    func getFeaturedApp() async throws -> Application

    func getCategories() async throws -> [Category]
    func getCategory(_ id: String) async throws -> Category

    func getApplications() async throws -> [Application]
    func getApplication(_ id: String) async throws -> Application
}
