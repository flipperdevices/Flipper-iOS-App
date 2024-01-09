import Foundation

public struct ApplicationRequest: CatalogRequest {
    public typealias Result = Application

    var path: String { "0/application/\(uid)" }
    var queryItems: [URLQueryItem] = []

    let baseURL: URL
    let uid: String

    init(baseURL: URL, uid: String) {
        self.baseURL = baseURL
        self.uid = uid
    }

    public func target(_ target: String?) -> Self {
        if let target {
            return setQueryItem(name: "target", value: target)
        } else {
            return self
        }
    }

    public func api(_ api: String?) -> Self {
        if let api {
            return setQueryItem(name: "api", value: api)
        } else {
            return self
        }
    }

    public func releaseBuild(_ hasRelease: Bool) -> Self {
        setQueryItem(name: "is_latest_release_version", value: hasRelease)
    }
}
