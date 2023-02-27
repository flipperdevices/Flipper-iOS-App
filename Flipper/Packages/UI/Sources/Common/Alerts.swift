import SwiftUI

extension Alert {
    static var unsupportedDeviceIssue: Alert {
        .init(
            title: .init(
                "Outdated firmware version"),
            message: .init(
                "Firmware version on your Flipper is not supported. " +
                "Please update it via PC."))
    }
}
