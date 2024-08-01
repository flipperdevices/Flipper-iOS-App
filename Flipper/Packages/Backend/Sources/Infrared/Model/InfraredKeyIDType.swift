import Foundation

public enum KeyIDType: String, Decodable {
    case name = "NAME"
    case sha256 = "SHA_256"
    case md5 = "MD5"
}

public struct NameKeyIDType: Decodable, Equatable {
    public let name: String

    enum CodingKeys: String, CodingKey {
        case name = "key_name"
    }
}

public struct SHA256KeyIDType: Decodable, Equatable {
    public let name: String
    public let hash: String

    enum CodingKeys: String, CodingKey {
        case name = "key_name"
        case hash = "sha_256_string"
    }
}

public struct MD5KeyIDType: Decodable, Equatable {
    public let name: String
    public let hash: String

    enum CodingKeys: String, CodingKey {
        case name = "key_name"
        case hash = "md5_string"
    }
}
