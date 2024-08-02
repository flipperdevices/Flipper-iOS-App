import Foundation

public struct InfraredSelection: Decodable, Equatable {
    public let signal: InfraredSignal?
    public let file: InfraredFile?

    enum CodingKeys: String, CodingKey {
        case signal = "signal_response"
        case file = "ifr_file_model"
    }

    init(
        signal: InfraredSignal? = nil,
        file: InfraredFile? = nil
    ) {
        self.signal = signal
        self.file = file
    }
}
