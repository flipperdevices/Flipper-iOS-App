import Foundation

public enum InfraredSignalModelDataType: String, Decodable {
    case raw
    case parsed
}

public enum InfraredSignalModelData: Decodable, Equatable {
    case raw(Raw)
    case parsed(Parsed)
    case unknown

    public struct Raw: Decodable, Equatable  {
        let frequency: String
        let dutyCycle: String
        let data: String

        enum CodingKeys: String, CodingKey {
            case frequency
            case dutyCycle = "duty_cycle"
            case data
        }
    }

    public struct Parsed: Decodable, Equatable  {
        let `protocol`: String
        let address: String
        let command: String

        enum CodingKeys: String, CodingKey {
            case `protocol` = "protocol"
            case address
            case command
        }
    }
}


