import Infrared

public struct InfraredSignal {
    public let id: Int
    public let message: String
    public let category: String

    public let button: InfraredButtonType
    public let type: InfraredSignalType

    public init(_ signal: Infrared.InfraredSignal) {
        self.id = signal.model.id
        self.message = signal.message
        self.category = signal.categoryName

        self.button = InfraredButtonType(signal.data)
        self.type = InfraredSignalType(signal.model.remote)
    }
}

public enum InfraredSignalType {
    case raw(Raw)
    case parsed(Parsed)

    public struct Raw: Equatable {
        let frequency: String
        let dutyCycle: String
        let data: String
        let name: String
    }

    public struct Parsed: Equatable {
        let `protocol`: String
        let address: String
        let command: String
        let name: String
    }

    init(_ data: Infrared.InfraredSignalRemote) {
        self =  switch data {
        case .raw(let raw):
                .raw(
                    .init(
                        frequency: raw.frequency,
                        dutyCycle: raw.dutyCycle,
                        data: raw.data,
                        name: raw.name
                    )
                )
        case .parsed(let parsed):
                .parsed(
                    .init(
                        protocol: parsed.protocol,
                        address: parsed.address,
                        command: parsed.command,
                        name: parsed.name
                    )
                )
        }
    }

    private var contentType: String {
        switch self {
        case .parsed(let parsed):
            """
            name: \(parsed.name)
            type: parsed
            protocol: \(parsed.protocol)
            address: \(parsed.address)
            command: \(parsed.command)
            """
        case .raw(let raw):
            """
            name: \(raw.name)
            type: raw
            frequency: \(raw.frequency)
            duty_cycle: \(raw.dutyCycle)
            data: \(raw.data)
            """
        }
    }

    public var content: String {
        """
        Filetype: IR signals file
        Version: 1
        #
        \(contentType)
        """
    }
}
