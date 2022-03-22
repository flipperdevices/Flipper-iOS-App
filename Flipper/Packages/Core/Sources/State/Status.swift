public enum Status: CustomStringConvertible {
    case noDevice
    case unsupportedDevice
    case connecting
    case connected
    case disconnected
    case synchronizing
    case synchronized
    case pairingIssue
    case preParing
    case pairing
    case failed

    public var isOnline: Bool {
        switch self {
        case .connected, .synchronized, .synchronizing: return true
        default: return false
        }
    }

    public var description: String {
        switch self {
        case .noDevice: return "No device"
        case .unsupportedDevice: return "Unsupported"
        case .connecting: return "Connecting"
        case .connected: return "Connected"
        case .disconnected: return "Disconnected"
        case .synchronizing: return "Syncing"
        case .synchronized: return "Synced"
        case .pairingIssue: return "Pairing Issue"
        case .preParing: return "PreParing"
        case .pairing: return "Pairing"
        case .failed: return "Failed"
        }
    }
}

extension Status {
    init(_ state: Peripheral.State?) {
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
