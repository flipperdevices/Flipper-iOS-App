import Foundation

public enum KeyID: Decodable, Equatable {
    case name(NameKeyIDType)
    case sha256(SHA256KeyIDType)
    case md5(MD5KeyIDType)
    case unknown

    enum CodingKeys: String, CodingKey {
        case name = "key_name"
        case sha256 = "sha_256_string"
        case md5 = "md5_string"
        case type
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        guard let type = try? container.decode(
            KeyIDType.self,
            forKey: .type)
        else {
            self = .unknown
            return
        }

        switch type {
        case .name:
            let data = try NameKeyIDType(from: decoder)
            self = .name(data)
        case .sha256:
            let data = try SHA256KeyIDType(from: decoder)
            self = .sha256(data)
        case .md5:
            let data = try MD5KeyIDType(from: decoder)
            self = .md5(data)
        }
    }
}
