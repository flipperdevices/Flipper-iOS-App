import Foundation

public enum InfraredSignalData: Decodable, Equatable {
    case raw(RawSignalType)
    case parsed(ParsedSignalType)
    case unknown

    enum CodingKeys: String, CodingKey {
        case type
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        guard let type = try? container.decode(
            InfraredSignalDataType.self,
            forKey: .type)
        else {
            self = .unknown
            return
        }

        switch type {
        case .raw:
            let data = try RawSignalType(from: decoder)
            self = .raw(data)
        case .parsed:
            let data = try ParsedSignalType(from: decoder)
            self = .parsed(data)
        }
    }
}
