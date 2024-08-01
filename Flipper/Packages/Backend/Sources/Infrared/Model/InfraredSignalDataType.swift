import Foundation

public enum InfraredSignalDataType: String, Decodable {
    case raw
    case parsed
}

public struct RawSignalType: Decodable, Equatable {
    public let frequency: String
    public let dutyCycle: String
    public let data: String

    enum CodingKeys: String, CodingKey {
        case frequency = "frequency"
        case dutyCycle = "duty_cycle"
        case data = "data"
    }
}

public struct ParsedSignalType: Decodable, Equatable {
    public let `protocol`: String
    public let address: String
    public let command: String

    enum CodingKeys: String, CodingKey {
        case `protocol` = "protocol"
        case address = "address"
        case command = "command"
    }
}
