import Foundation

public enum InfraredButtonData: Decodable, Equatable {
    case text(TextButtonData)
    case icon(IconButtonData)
    case base64Image(Base64ImageButtonData)
    case navigation(NavigationButtonData)
    case volume(VolumeButtonData)
    case channel(ChannelButtonData)
    case unknown

    enum CodingKeys: String, CodingKey {
        case type
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        guard let type = try? container.decode(
            InfraredButtonDataType.self,
            forKey: .type)
        else {
            self = .unknown
            return
        }

        switch type {
        case .text:
            let data = try TextButtonData(from: decoder)
            self = .text(data)
        case .icon:
            let data = try IconButtonData(from: decoder)
            self = .icon(data)
        case .base64Image:
            let data = try Base64ImageButtonData(from: decoder)
            self = .base64Image(data)
        case .navigation:
            let data = try NavigationButtonData(from: decoder)
            self = .navigation(data)
        case .channel:
            let data = try ChannelButtonData(from: decoder)
            self = .channel(data)
        case .volume:
            let data = try VolumeButtonData(from: decoder)
            self = .volume(data)
        }
    }
}

public extension InfraredButtonData {
    var containerDefaultWidth: Int {
        switch self {
        case .text, .icon, .base64Image, .unknown: 1
        case .navigation: 3
        case .volume, .channel: 1
        }
    }

    var containerDefaultHeight: Int {
        switch self {
        case .text, .icon, .base64Image, .unknown: 1
        case .navigation: 3
        case .volume, .channel: 3
        }
    }

    var contentDefaultWidth: Int {
        switch self {
        case .text, .icon, .base64Image, .unknown: 1
        case .navigation: 3
        case .volume, .channel: 1
        }
    }

    var contentDefaultHeight: Int {
        switch self {
        case .text, .icon, .base64Image, .unknown: 1
        case .navigation: 3
        case .volume, .channel: 3
        }
    }
}
