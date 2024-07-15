import Backend
import Foundation

public struct BuildRequest: BackendRequest {
    public typealias Result = Data
    public var path: String { "0/application/version/\(uid)/build/compatible" }
    public var queryItems: [URLQueryItem] = []

    public let baseURL: URL
    public let uid: String

    public init(baseURL: URL, uid: String) {
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
