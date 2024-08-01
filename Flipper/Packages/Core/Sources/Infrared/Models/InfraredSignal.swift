import Infrared

public struct InfraredSignal {
    public let message: String
    public let button: InfraredButtonType

    public init(_ signal: Infrared.InfraredSignal) {
        self.message = signal.response.message
        self.button = InfraredButtonType(signal.response.data)
    }
}
