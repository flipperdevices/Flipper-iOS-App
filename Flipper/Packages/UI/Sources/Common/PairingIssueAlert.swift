import SwiftUI

enum PairingIssue {
    static let title = "Pairing Issue"
    static let message =
        "Forget your device in bluetooth " +
        "settings and restart the app"

    static var alert: Alert {
        .init(
            title: .init(title),
            message: .init(message))
    }
}
