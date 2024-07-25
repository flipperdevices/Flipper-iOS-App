import Backend
import Foundation

public struct BrandsRequest: BackendRequest {
    public typealias Result = InfraredBrands

    public var path: String { "brands" }
    public var queryItems: [URLQueryItem]

    public let baseURL: URL

    public init(baseURL: URL, categoryId: Int) {
        self.baseURL = baseURL
        self.queryItems = [ .init(name: "category_id", value: categoryId) ]
    }
}
