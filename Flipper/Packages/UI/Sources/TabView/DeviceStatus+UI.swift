import Core
import SwiftUI

extension Device.Status {
    var color: Color {
        switch self {
        case .noDevice: return .black40
        case .unsupported: return .sRed
        case .outdatedMobile: return .sRed
        case .connecting: return .black40
        case .connected: return .a2
        case .disconnected: return .black40
        case .synchronizing: return .a2
        case .synchronized: return .a2
        case .updating: return .black40
        case .invalidPairing: return .sRed
        case .pairingFailed: return .sRed
        }
    }

    var iconName: String {
        return switch self {
        case .noDevice: "no_device"
        case .unsupported: "unsupported"
        case .outdatedMobile: "unsupported"
        case .connecting: "connecting"
        case .connected: "connected"
        case .disconnected: "disconnected"
        case .synchronizing: "syncing"
        case .synchronized: "synced"
        case .updating: "connecting"
        case .invalidPairing: "pairing_failed"
        case .pairingFailed: "pairing_failed"
        }
    }
}
