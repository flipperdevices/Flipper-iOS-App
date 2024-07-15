import Backend
import Foundation

public struct CategoryRequest: BackendRequest {
    public typealias Result = Category

    public var path: String { "0/category/\(uid)" }
    public var queryItems: [URLQueryItem] = []

    public let baseURL: URL
    public let uid: String

    init(baseURL: URL, uid: String) {
        self.baseURL = baseURL
        self.uid = uid
    }
}
