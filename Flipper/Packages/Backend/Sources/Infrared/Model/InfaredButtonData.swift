import Foundation

public enum InfraredButtonData: Codable, Equatable {
    case text(Text)
    case icon(Icon)
    case base64Image(Base64Image)
    case navigation(Navigation)
    case volume(Volume)
    case channel(Channel)
    case unknown

    enum CodingKeys: String, CodingKey {
        case type
    }

    enum `Type`: String, Decodable {
        case text = "TEXT"
        case icon = "ICON"
        case base64Image = "BASE64_IMAGE"
        case navigation = "NAVIGATION"
        case channel = "CHANNEL"
        case volume = "VOLUME"
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        guard let type = try? container.decode(
            `Type`.self,
            forKey: .type
        ) else {
            self = .unknown
            return
        }

        self = switch type {
        case .text:
            .text(try Text(from: decoder))
        case .icon:
            .icon(try Icon(from: decoder))
        case .base64Image:
            .base64Image(try Base64Image(from: decoder))
        case .navigation:
            .navigation(try Navigation(from: decoder))
        case .channel:
            .channel(try Channel(from: decoder))
        case .volume:
            .volume(try Volume(from: decoder))
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .text(let text):
            try container.encode(`Type`.text.rawValue, forKey: .type)
            try text.encode(to: encoder)
        case .icon(let icon):
            try container.encode(`Type`.icon.rawValue, forKey: .type)
            try icon.encode(to: encoder)
        case .base64Image(let base64Image):
            try container.encode(`Type`.base64Image.rawValue, forKey: .type)
            try base64Image.encode(to: encoder)
        case .navigation(let navigation):
            try container.encode(`Type`.navigation.rawValue, forKey: .type)
            try navigation.encode(to: encoder)
        case .volume(let volume):
            try container.encode(`Type`.volume.rawValue, forKey: .type)
            try volume.encode(to: encoder)
        case .channel(let channel):
            try container.encode(`Type`.channel.rawValue, forKey: .type)
            try channel.encode(to: encoder)
        case .unknown:
            break
        }
    }

    public struct Text: Codable, Equatable {
        public let keyId: InfraredKeyID
        public let text: String

        enum CodingKeys: String, CodingKey {
            case keyId = "key_id"
            case text
        }
    }

    public struct Icon: Codable, Equatable {
        public let keyId: InfraredKeyID
        public let type: `Type`

        enum CodingKeys: String, CodingKey {
            case keyId = "key_id"
            case type = "icon_id"
        }

        public enum `Type`: String, Codable {
            case back = "BACK"
            case home = "HOME"
            case info = "INFO"
            case more = "MORE"
            case mute = "MUTE"
            case power = "POWER"
            case cool = "COOL"
            case heat = "HEAT"
        }
    }

    public struct Base64Image: Codable, Equatable {
        public let keyId: InfraredKeyID
        public let pngBase64: String

        enum CodingKeys: String, CodingKey {
            case keyId = "key_id"
            case pngBase64 = "png_base64"
        }
    }

    public struct Navigation: Codable, Equatable {
        public let upKeyId: InfraredKeyID
        public let leftKeyId: InfraredKeyID
        public let downKeyId: InfraredKeyID
        public let rightKeyId: InfraredKeyID
        public let okKeyId: InfraredKeyID

        enum CodingKeys: String, CodingKey {
            case upKeyId = "up_key_id"
            case leftKeyId = "left_key_id"
            case downKeyId = "down_key_id"
            case rightKeyId = "right_key_id"
            case okKeyId = "ok_key_id"
        }
    }

    public struct Volume: Codable, Equatable {
        public let addKeyId: InfraredKeyID
        public let reduceKeyId: InfraredKeyID

        enum CodingKeys: String, CodingKey {
            case addKeyId = "add_key_id"
            case reduceKeyId = "reduce_key_id"
        }
    }

    public struct Channel: Codable, Equatable {
        public let addKeyId: InfraredKeyID
        public let reduceKeyId: InfraredKeyID

        enum CodingKeys: String, CodingKey {
            case addKeyId = "add_key_id"
            case reduceKeyId = "reduce_key_id"
        }
    }
}

fileprivate extension KeyedDecodingContainer {
    func decode(
        _ type: InfraredButtonData.Type,
        forKey key: K
    ) throws -> InfraredKeyID {
        return try decodeIfPresent(InfraredKeyID.self, forKey: key) ?? .unknown
    }
}
