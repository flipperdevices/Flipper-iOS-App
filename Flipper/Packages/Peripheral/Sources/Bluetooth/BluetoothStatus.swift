public enum BluetoothStatus: Equatable {
    public enum NotReadyReason: String, Equatable {
        case poweredOff
        case preparing
        case unauthorized
        case unsupported
    }

    case ready
    case notReady(NotReadyReason)

    public static var preparing: BluetoothStatus {
        .notReady(.preparing)
    }
}
