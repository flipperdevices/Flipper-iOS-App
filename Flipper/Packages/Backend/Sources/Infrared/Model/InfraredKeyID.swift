import Foundation

public enum InfraredKeyID: Codable, Equatable {
    case name(Name)
    case sha256(SHA256)
    case unknown

    enum CodingKeys: String, CodingKey {
        case name = "key_name"
        case sha256 = "sha_256_string"
        case type
    }

    enum `Type`: String, Decodable {
        case name = "NAME"
        case sha256 = "SHA_256"
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        guard let type = try? container.decode(
            `Type`.self,
            forKey: .type)
        else {
            self = .unknown
            return
        }

        self = switch type {
        case .name:
            .name(try Name(from: decoder))
        case .sha256:
            .sha256(try SHA256(from: decoder))
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .name(let name):
            try container.encode(`Type`.name.rawValue, forKey: .type)
            try name.encode(to: encoder)
        case .sha256(let sha256):
            try container.encode(`Type`.sha256.rawValue, forKey: .type)
            try sha256.encode(to: encoder)
        case .unknown:
            break
        }
    }

    public struct Name: Codable, Equatable {
        public let name: String

        enum CodingKeys: String, CodingKey {
            case name = "key_name"
        }
    }

    public struct SHA256: Codable, Equatable {
        public let name: String
        public let hash: String

        enum CodingKeys: String, CodingKey {
            case name = "key_name"
            case hash = "sha_256_string"
        }
    }

    public struct MD5: Codable, Equatable {
        public let name: String
        public let hash: String

        enum CodingKeys: String, CodingKey {
            case name = "key_name"
            case hash = "md5_string"
        }
    }
}
