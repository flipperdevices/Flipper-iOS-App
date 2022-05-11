import Peripheral

public enum DeviceStatus: CustomStringConvertible {
    case noDevice
    case unsupportedDevice
    case connecting
    case connected
    case disconnected
    case synchronizing
    case synchronized
    case updating
    case invalidPairing
    case pairingFailed

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
        case .updating: return "Updating"
        case .invalidPairing: return "Pairing Failed"
        case .pairingFailed: return "Pairing Failed"
        }
    }
}

extension DeviceStatus {
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
