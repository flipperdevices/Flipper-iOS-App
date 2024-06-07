import Foundation

extension URL {
    // MARK: Apps
    private static let catalog = "https://catalog.flipperzero.one/api/v0/"

    static var mockValidAppScreenshotFirst: URL {
        .init(
            string: catalog + "application/version/assets/6655c738177869915682353e"
        )!
    }
    static var mockValidAppScreenshotSecond: URL {
        .init(
            string: catalog + "application/version/assets/6655c7381778699156823540"
        )!
    }
    static var mockValidAppScreenshotThird: URL {
        .init(
            string: catalog + "application/version/assets/6655c7381778699156823542"
        )!
    }
    static var mockUnknownAppScreenshot: URL {
        .init(string: "https://420.com")!
    }
}
