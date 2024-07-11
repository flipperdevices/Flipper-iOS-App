import Foundation

public enum InfraredButtonData: Equatable {
    case text(TextButtonData)
    case icon(IconButtonData)
    case base64Image(Base64ImageButtonData)
    case navigation(NavigationButtonData)
    case volume(VolumeButtonData)
    case channel(ChannelButtonData)
    case unknown
}

extension InfraredButtonData {
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
