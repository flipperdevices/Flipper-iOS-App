import Foundation

public struct BundleRequest: CatalogRequest {
    public typealias Result = Data

    var path: String { "application/version/\(uid)/build/\(target)/\(api)" }
    var queryItems: [URLQueryItem] = []

    let baseURL: URL
    let uid: String
    let target: String
    let api: String

    init(baseURL: URL, uid: String, target: String, api: String) {
        self.baseURL = baseURL
        self.uid = uid
        self.target = target
        self.api = api
    }
}
