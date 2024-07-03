import Foundation

public enum InfraredButtonDataType: String, Decodable {
    case text = "TEXT"
    case icon = "ICON"
    case base64Image = "BASE64_IMAGE"
    case navigation = "NAVIGATION"
    case channel = "CHANNEL"
    case volume = "VOLUME"
}

public struct TextButtonData: Decodable, Equatable {
    public let keyId: KeyID
    public let text: String

    enum CodingKeys: String, CodingKey {
        case keyId = "key_id"
        case text
    }
}

public struct IconButtonData: Decodable, Equatable {
    public let keyId: KeyID
    public let icon: IconType

    enum CodingKeys: String, CodingKey {
        case keyId = "key_id"
        case icon = "icon_id"
    }

    public enum IconType: String, Decodable {
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

public struct Base64ImageButtonData: Decodable, Equatable {
    public let keyId: KeyID
    public let pngBase64: String

    enum CodingKeys: String, CodingKey {
        case keyId = "key_id"
        case pngBase64 = "png_base64"
    }
}

public struct NavigationButtonData: Decodable, Equatable {
    public let upKeyId: KeyID
    public let leftKeyId: KeyID
    public let downKeyId: KeyID
    public let rightKeyId: KeyID
    public let okKeyId: KeyID

    enum CodingKeys: String, CodingKey {
        case upKeyId = "up_key_id"
        case leftKeyId = "left_key_id"
        case downKeyId = "down_key_id"
        case rightKeyId = "right_key_id"
        case okKeyId = "ok_key_id"
    }
}

public struct VolumeButtonData: Decodable, Equatable {
    public let addKeyId: KeyID
    public let reduceKeyId: KeyID

    enum CodingKeys: String, CodingKey {
        case addKeyId = "add_key_id"
        case reduceKeyId = "reduce_key_id"
    }
}

public struct ChannelButtonData: Decodable, Equatable {
    public let addKeyId: KeyID
    public let reduceKeyId: KeyID

    enum CodingKeys: String, CodingKey {
        case addKeyId = "add_key_id"
        case reduceKeyId = "reduce_key_id"
    }
}
