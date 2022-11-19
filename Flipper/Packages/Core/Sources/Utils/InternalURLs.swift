import Foundation

extension URL {
    // swiftlint:disable force_unwrapping

    public static var flipperMobile: URL {
        .init(string: "flipper://")!
    }

    public static var widgetSettings: URL {
        .init(string: "flipper://widget-settings")!
    }
}
