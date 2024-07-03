import Foundation

public struct KeyID: Decodable, Equatable {
    public let type: String
    public let keyName: String
    public let sha256String: String

    public enum CodingKeys: String, CodingKey {
        case type
        case keyName = "key_name"
        case sha256String = "sha_256_string"
    }
}
