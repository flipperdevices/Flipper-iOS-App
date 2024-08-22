import Foundation

public enum InfraredSelection: Decodable, Equatable {
    case signal(InfraredSignal)
    case file(InfraredFile)

    enum CodingKeys: String, CodingKey {
        case signal = "signal_response"
        case file = "ifr_file_model"
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let signal = try? container.decode(
            InfraredSignal.self,
            forKey: .signal
        ) {
            self = .signal(signal)
        } else {
            let file = try container.decode(InfraredFile.self, forKey: .file)
            self = .file(file)
        }
    }
}
