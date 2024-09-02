import Backend
import Foundation

public struct BrandFilesRequest: BackendRequest {
    public typealias Result = InfraredBrandFiles

    public var path: String { "infrareds" }
    public var queryItems: [URLQueryItem]

    public let baseURL: URL

    public init(baseURL: URL, brandId: Int) {
        self.baseURL = baseURL
        self.queryItems = [ .init(name: "brand_id", value: brandId) ]
    }
}
