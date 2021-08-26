enum BluetoothStatus: Equatable {
    enum NotReadyReason: String {
        case poweredOff
        case preparing
        case unauthorized
        case unsupported
    }

    case ready
    case notReady(NotReadyReason)
}
