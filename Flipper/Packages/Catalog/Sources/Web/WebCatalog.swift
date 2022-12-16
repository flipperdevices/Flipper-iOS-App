import Foundation

public class WebCatalog: CatalogService {
    private let baseURL = URL("https://catalog.flipp.dev/api/v0")

    private var featuredURL: URL {
        baseURL.appendingPathComponent("application/featured")
    }

    private var categoriesURL: URL {
        baseURL.appendingPathComponent("category")
    }

    private var applicationsURL: URL {
        baseURL.appendingPathComponent("application")
    }

    enum Error: Swift.Error {
        case invalidResponse
    }

    public init() {
    }

    public func getFeaturedApp() async throws -> Application {
        let apps = try await object(from: featuredURL) as [Application]
        guard let featured = apps.first else {
            throw Error.invalidResponse
        }
        return featured
    }

    public func getCategories() async throws -> [Category] {
        try await object(from: categoriesURL)
    }

    public func getCategory(_ id: String) async throws -> Category {
        try await object(from: categoriesURL.appendingPathComponent(id))
    }

    public func getApplications() async throws -> [Application] {
        try await object(from: applicationsURL)
    }

    public func getApplication(_ id: String) async throws -> Application {
        try await object(from: applicationsURL.appendingPathComponent(id))
    }

    private func object<T: Decodable>(from url: URL) async throws -> T {
        let data = try await data(from: url)
        return try JSONDecoder().decode(T.self, from: data)
    }

    private func data(from url: URL) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw Error.invalidResponse
        }
        print(String(decoding: data, as: UTF8.self))
        return data
    }
}
