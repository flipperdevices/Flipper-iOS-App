public enum Status: CustomStringConvertible {
    case noDevice
    case connecting
    case connected
    case disconnected
    case synchronizing

    public var description: String {
        switch self {
        case .noDevice: return "No device"
        case .connecting: return "Connecting"
        case .connected: return "Connected"
        case .disconnected: return "Disconnected"
        case .synchronizing: return "Connected"
        }
    }
}

extension Status {
    public init(_ state: Peripheral.State?) {
        guard let state = state else {
            self = .noDevice
            return
        }
        switch state {
        case .connected: self = .connected
        case .connecting: self = .connecting
        case .disconnected: self = .disconnected
        case .disconnecting: self = .disconnected
        }
    }
}
