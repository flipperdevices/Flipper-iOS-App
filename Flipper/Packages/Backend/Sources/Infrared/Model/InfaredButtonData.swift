import Foundation

public enum InfraredButtonData: Codable, Equatable {
    case text(Text)
    case icon(Icon)
    case power(Power)
    case base64Image(Base64Image)
    case volume(Volume)
    case channel(Channel)
    case shutter(Shutter)
    case navigation(Navigation)
    case okNavigation(OkNavigation)
    case unknown

    enum CodingKeys: String, CodingKey {
        case type
    }

    enum `Type`: String, Decodable {
        case text = "TEXT"
        case icon = "ICON"
        case power = "POWER"
        case shutter = "SHUTTER"
        case base64Image = "BASE64_IMAGE"
        case navigation = "NAVIGATION"
        case okNavigation = "OK_NAVIGATION"
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
        case .power:
            .power(try Power(from: decoder))
        case .base64Image:
            .base64Image(try Base64Image(from: decoder))
        case .channel:
            .channel(try Channel(from: decoder))
        case .volume:
            .volume(try Volume(from: decoder))
        case .shutter:
            .shutter(try Shutter(from: decoder))
        case .navigation:
            .navigation(try Navigation(from: decoder))
        case .okNavigation:
            .okNavigation(try OkNavigation(from: decoder))
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
        case .power(let power):
            try container.encode(`Type`.power.rawValue, forKey: .type)
            try power.encode(to: encoder)
        case .base64Image(let base64Image):
            try container.encode(`Type`.base64Image.rawValue, forKey: .type)
            try base64Image.encode(to: encoder)
        case .volume(let volume):
            try container.encode(`Type`.volume.rawValue, forKey: .type)
            try volume.encode(to: encoder)
        case .channel(let channel):
            try container.encode(`Type`.channel.rawValue, forKey: .type)
            try channel.encode(to: encoder)
        case .shutter(let shutter):
            try container.encode(`Type`.shutter.rawValue, forKey: .type)
            try shutter.encode(to: encoder)
        case .navigation(let navigation):
            try container.encode(`Type`.navigation.rawValue, forKey: .type)
            try navigation.encode(to: encoder)
        case .okNavigation(let okNavigation):
            try container.encode(`Type`.okNavigation.rawValue, forKey: .type)
            try okNavigation.encode(to: encoder)
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
            case addPlusMore = "ADD_PLUS_MORE"
            case aux = "AUX"
            case back = "BACK"
            case brightLess = "BRIGHT_LESS"
            case brightMore = "BRIGHT_MORE"
            case camera = "CAMERA"
            case chDown = "CH_DOWN"
            case chUp = "CH_UP"
            case coldWind = "COLD_WIND"
            case cool = "COOL"
            case delete = "DELETE"
            case down = "DOWN"
            case eject = "EJECT"
            case energySave = "ENERGY_SAVE"
            case exit = "EXIT"
            case fanHigh = "FAN_HIGH"
            case fanLow = "FAN_LOW"
            case fanMedium = "FAN_MEDIUM"
            case fanOff = "FAN_OFF"
            case fanSpeed = "FAN_SPEED"
            case fanSpeedDown = "FAN_SPEED_DOWN"
            case fanSpeedUp = "FAN_SPEED_UP"
            case far = "FAR"
            case favorite = "FAVORITE"
            case focusLess = "FOCUS_LESS"
            case focusMore = "FOCUS_MORE"
            case forward = "FORWARD"
            case heat = "HEAT"
            case heatAdd = "HEAT_ADD"
            case heatReduce = "HEAT_REDUCE"
            case home = "HOME"
            case info = "INFO"
            case left = "LEFT"
            case light = "LIGHT"
            case liveTV = "LIVE_TV"
            case menu = "MENU"
            case mode = "MODE"
            case more = "MORE"
            case mute = "MUTE"
            case near = "NEAR"
            case next = "NEXT"
            case ok = "OK"
            case oscillate = "OSCILLATE"
            case pause = "PAUSE"
            case play = "PLAY"
            case power = "POWER"
            case previous = "PREVIOUS"
            case record = "RECORD"
            case removeMinusLess = "REMOVE_MINUS_LESS"
            case reset = "RESET"
            case rewind = "REWIND"
            case right = "RIGHT"
            case settings = "SETTINGS"
            case shakeWind = "SHAKE_WIND"
            case sleep = "SLEEP"
            case stop = "STOP"
            case swing = "SWING"
            case temperatureDown = "TEMPERATURE_DOWN"
            case temperatureUp = "TEMPERATURE_UP"
            case timer = "TIMER"
            case timerAdd = "TIMER_ADD"
            case timerReduce = "TIMER_REDUCE"
            case tv = "TV"
            case up = "UP"
            case vod = "VOD"
            case volDown = "VOL_DOWN"
            case volUp = "VOL_UP"
            case windSpeed = "WIND_SPEED"
            case windType = "WIND_TYPE"
            case zoomIn = "ZOOM_IN"
            case zoomOut = "ZOOM_OUT"
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

    public struct Power: Codable, Equatable {
        public let keyId: InfraredKeyID

        enum CodingKeys: String, CodingKey {
            case keyId = "key_id"
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

    public struct Shutter: Codable, Equatable {
        public let keyId: InfraredKeyID

        enum CodingKeys: String, CodingKey {
            case keyId = "key_id"
        }

        public init(keyId: InfraredKeyID) {
            self.keyId = keyId
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

    public struct OkNavigation: Codable, Equatable {
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

        public init(
            upKeyId: InfraredKeyID,
            leftKeyId: InfraredKeyID,
            downKeyId: InfraredKeyID,
            rightKeyId: InfraredKeyID,
            okKeyId: InfraredKeyID
        ) {
            self.upKeyId = upKeyId
            self.leftKeyId = leftKeyId
            self.downKeyId = downKeyId
            self.rightKeyId = rightKeyId
            self.okKeyId = okKeyId
        }
    }

    public struct Navigation: Codable, Equatable {
        public let upKeyId: InfraredKeyID
        public let leftKeyId: InfraredKeyID
        public let downKeyId: InfraredKeyID
        public let rightKeyId: InfraredKeyID

        enum CodingKeys: String, CodingKey {
            case upKeyId = "up_key_id"
            case leftKeyId = "left_key_id"
            case downKeyId = "down_key_id"
            case rightKeyId = "right_key_id"
        }

        public init(
            upKeyId: InfraredKeyID,
            leftKeyId: InfraredKeyID,
            downKeyId: InfraredKeyID,
            rightKeyId: InfraredKeyID
        ) {
            self.upKeyId = upKeyId
            self.leftKeyId = leftKeyId
            self.downKeyId = downKeyId
            self.rightKeyId = rightKeyId
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
