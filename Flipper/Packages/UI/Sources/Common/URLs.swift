import UIKit
import Foundation

extension URL {
    // swiftlint:disable force_unwrapping

    // MARK: System

    static var settings: URL {
        .init(string: UIApplication.openSettingsURLString)!
    }

    static var systemSettings: URL {
        .init(string: "App-Prefs:root=")!
    }

    // MARK: AppStore

    static var appStore: URL {
        .init(string: "https://apps.apple.com/app/id1534655259")!
    }

    // MARK: Welcome

    static var termsOfServiceURL: URL {
        .init(string: "https://flipp.dev/flipper-app-terms-of-service")!
    }

    static var privacyPolicyURL: URL {
        .init(string: "https://flipp.dev/flipper-app-privacy-policy")!
    }

    // MARK: Help

    static var helpToKnowName: URL {
        .init(string: "https://flipp.dev/passport")!
    }

    static var helpToTurnOnBluetooth: URL {
        .init(string: "https://flipp.dev/bluetooth-on")!
    }

    static var helpToInstallFirmware: URL {
        .init(string: "https://flipp.dev/firmware-update")!
    }

    static var helpToReboot: URL {
        .init(string: "https://flipp.dev/reboot")!
    }

    static var helpToFactoryReset: URL {
        .init(string: "https://flipp.dev/storage-repair")!
    }

    // MARK: Resources

    static var forum: URL {
        .init(string: "https://forum.flipperzero.one")!
    }

    static var github: URL {
        .init(string: "https://github.com/flipperdevices")!
    }
}
