import Foundation

public struct CategoryRequest: CatalogRequest {
    public typealias Result = Category

    var path: String { "0/category/\(uid)" }
    var queryItems: [URLQueryItem] = []

    let baseURL: URL
    let uid: String

    init(baseURL: URL, uid: String) {
        self.baseURL = baseURL
        self.uid = uid
    }
}
