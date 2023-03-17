import Foundation

extension String {
    static var appGroup: String {
        "group.com.flipperdevices.main"
    }
}

extension URL {
    static var shareBaseURL: URL {
        "https://flpr.app/s"
    }
    static var shareFileBaseURL: URL {
        "https://flpr.app/sf"
    }
    static var transferBaseURL: URL {
        "https://transfer.flpr.app"
    }
}

extension URL {
    static var firmwareManifestURL: URL {
        "https://update.flipperzero.one/firmware/directory.json"
    }
}
