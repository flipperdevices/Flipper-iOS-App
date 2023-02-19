import Peripheral

extension Device {
    public enum Status: CustomStringConvertible {
        case noDevice
        case connecting
        case connected
        case disconnected
        case synchronizing
        case synchronized
        case updating
        case unsupported
        case invalidPairing
        case pairingFailed

        public var description: String {
            switch self {
            case .noDevice: return "No device"
            case .connecting: return "Connecting"
            case .connected: return "Connected"
            case .disconnected: return "Disconnected"
            case .synchronizing: return "Syncing"
            case .synchronized: return "Synced"
            case .updating: return "Updating"
            case .unsupported: return "Unsupported"
            case .invalidPairing: return "Pairing Failed"
            case .pairingFailed: return "Pairing Failed"
            }
        }
    }
}

extension Device.Status {
    init(_ state: FlipperState?) {
        guard let state = state else {
            self = .noDevice
            return
        }
        switch state {
        case .connected: self = .connected
        case .connecting: self = .connecting
        case .disconnected: self = .disconnected
        case .disconnecting: self = .disconnected
        case .pairingFailed: self = .pairingFailed
        case .invalidPairing: self = .invalidPairing
        }
    }
}
