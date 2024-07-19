import Backend
import Foundation

public struct CategoriesRequest: BackendRequest {
    public typealias Result = InfraredCategories

    public var path: String { "categories" }
    public var queryItems: [URLQueryItem] = []

    public let baseURL: URL

    public init(baseURL: URL) {
        self.baseURL = baseURL
    }
}
