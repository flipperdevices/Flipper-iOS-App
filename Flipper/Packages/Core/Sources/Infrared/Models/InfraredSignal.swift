import Infrared

public typealias InfraredSignalType = Infrared.InfraredSignalRemote

public struct InfraredSignal {
    public let id: Int
    public let message: String
    public let category: String

    public let button: InfraredButtonData
    public let type: InfraredSignalType

    public init(_ signal: Infrared.InfraredSignal) {
        self.id = signal.model.id
        self.message = signal.message
        self.category = signal.categoryName

        self.button = signal.data
        self.type = signal.model.remote
    }

    private var contentType: String {
        switch self.type {
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
