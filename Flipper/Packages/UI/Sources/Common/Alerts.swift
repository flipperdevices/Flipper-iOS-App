import SwiftUI

extension Alert {
    static var pairingIssue: Alert {
        .init(
            title: .init(
                "Pairing Failed"),
            message: .init(
                """
                1. Go to Bluetooth Settings
                2. Open Device Info
                3. Click Forget This Device
                """
            ),
            primaryButton: .default(.init("Cancel")),
            secondaryButton: .default(.init("Settings")) {
                Application.openSystemSettings()
            })
    }

    static var unsupportedDeviceIssue: Alert {
        .init(
            title: .init(
                "Outdated firmware version"),
            message: .init(
                "Firmware version on your Flipper is not supported. " +
                "Please update it via PC."))
    }

    static func connectionTimeout(retry: @escaping () -> Void) -> Alert {
        .init(
            title: .init(
                "Connection Failed"),
            message: .init(
                "Unable to connect to Flipper. " +
                "Try to connect again or use Help"),
            primaryButton: .default(.init("Cancel")),
            secondaryButton: .default(.init("Retry"), action: retry))
    }

    static func canceledOrIncorrectPin(retry: @escaping () -> Void) -> Alert {
        .init(
            title: .init(
                "Unable to Connect to Flipper"),
            message: .init(
                "Connection was canceled or the pairing " +
                "code was entered incorrectly"),
            primaryButton: .default(.init("Cancel")),
            secondaryButton: .default(.init("Retry"), action: retry))
    }
}
