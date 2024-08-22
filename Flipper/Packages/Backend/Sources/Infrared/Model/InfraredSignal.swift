public struct InfraredSignal: Decodable, Equatable {
    public let message: String
    public let categoryName: String
    public let data: InfraredButtonData
    public let model: InfraredSignalModel

    enum CodingKeys: String, CodingKey {
        case message
        case categoryName = "category_name"
        case data
        case model = "signal_model"
    }
}

public struct InfraredSignalModel: Decodable, Equatable {
    public let id: Int
    public let remote: InfraredSignalRemote
}

public enum InfraredSignalRemote: Decodable, Equatable {
    case raw(Raw)
    case parsed(Parsed)

    enum CodingKeys: String, CodingKey {
        case type
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(`Type`.self, forKey: .type)

        self = switch type {
        case .raw: .raw(try Raw(from: decoder))
        case .parsed: .parsed(try Parsed(from: decoder))
        }
    }

    enum `Type`: String, Decodable {
        case raw
        case parsed
    }

    public struct Raw: Decodable, Equatable {
        public let frequency: String
        public let dutyCycle: String
        public let data: String
        public let name: String

        enum CodingKeys: String, CodingKey {
            case frequency = "frequency"
            case dutyCycle = "duty_cycle"
            case data = "data"
            case name = "name"
        }
    }

    public struct Parsed: Decodable, Equatable {
        public let `protocol`: String
        public let address: String
        public let command: String
        public let name: String

        enum CodingKeys: String, CodingKey {
            case `protocol` = "protocol"
            case address = "address"
            case command = "command"
            case name = "name"
        }
    }
}
