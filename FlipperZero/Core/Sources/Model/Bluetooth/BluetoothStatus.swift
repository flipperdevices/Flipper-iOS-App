enum BluetoothStatus: Equatable {
    enum NotReadyReason: String, Equatable {
        case poweredOff
        case preparing
        case unauthorized
        case unsupported
    }

    case ready
    case notReady(NotReadyReason)
}
