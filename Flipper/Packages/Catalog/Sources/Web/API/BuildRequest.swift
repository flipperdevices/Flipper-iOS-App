import Foundation

public struct BuildRequest: CatalogRequest {
    public typealias Result = Data
    var path: String { "application/version/\(uid)/build/compatible" }
    var queryItems: [URLQueryItem] = []

    let baseURL: URL
    let uid: String

    init(baseURL: URL, uid: String) {
        self.baseURL = baseURL
        self.uid = uid
    }

    public func target(_ target: String) -> Self {
        setQueryItem(name: "target", value: target)
    }

    public func api(_ api: String) -> Self {
        setQueryItem(name: "api", value: api)
    }

    public func releaseBuild(_ hasRelease: Bool) -> Self {
        setQueryItem(name: "is_latest_release_version", value: hasRelease)
    }
}
