import SwiftUI

enum PairingIssue {
    static let title = "Pairing Issue"
    static let message =
        "Forget your device in bluetooth " +
        "settings and try again"

    static var alert: Alert {
        .init(
            title: .init(title),
            message: .init(message))
    }
}

enum ConnectTimeoutIssue {
    static let title = "Connection Failed"
    static let message =
        "Unable to connect to Flipper. Try to connect again or use Help"

    static func alert(retry: @escaping () -> Void) -> Alert {
        .init(
            title: .init(title),
            message: .init(message),
            primaryButton: .default(.init("Cancel")),
            secondaryButton: .default(.init("Retry"), action: retry))
    }
}

enum PairingCanceledOrIncorrectPinIssue {
    static let title = "Unable to Connect to Flipper"
    static let message =
        "Connection was canceled or the pairing " +
        "code was entered incorrectly"

    static func alert(retry: @escaping () -> Void) -> Alert {
        .init(
            title: .init(title),
            message: .init(message),
            primaryButton: .default(.init("Cancel")),
            secondaryButton: .default(.init("Retry"), action: retry))
    }
}
