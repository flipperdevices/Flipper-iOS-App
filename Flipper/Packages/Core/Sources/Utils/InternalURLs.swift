import Foundation

extension URL {
    // swiftlint:disable force_unwrapping

    public static var flipperMobile: URL {
        .init(string: "flipper://")!
    }

    public static var todayWidgetSettings: URL {
        .init(string: "flipper://todaywidget-settings")!
    }
}
