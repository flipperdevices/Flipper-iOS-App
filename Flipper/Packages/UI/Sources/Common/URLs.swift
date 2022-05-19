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
        .init(string: "https://docs.flipperzero.one/basics/control/dolphin#yj-flipper-name")!
    }

    static var helpToTurnOnBluetooth: URL {
        .init(string: "https://docs.flipperzero.one/basics/control/bluetooth#n3-turn-on-bluetooth")!
    }

    static var helpToInstallFirmware: URL {
        .init(string: "https://docs.flipperzero.one/basics/firmware-update")!
    }

    static var helpToReboot: URL {
        .init(string: "https://docs.flipperzero.one/basics/reboot")!
    }
}
