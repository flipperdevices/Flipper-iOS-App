import Macro
import UIKit
import Foundation

extension URL {

    // MARK: System

    static var settings: URL {
        .init(string: UIApplication.openSettingsURLString) ?? systemSettings
    }

    static var notificationSettings: URL {
        var url: URL? = nil
        if #available(iOS 16, *) {
            url = .init(string: UIApplication.openNotificationSettingsURLString)
        } else if #available(iOS 15.4, *) {
            url = .init(string: UIApplicationOpenNotificationSettingsURLString)
        } else {
            url = .init(string: UIApplication.openSettingsURLString)
        }
        return url ?? systemSettings
    }

    static var systemSettings = #URL(
        "App-Prefs:root="
    )

    // MARK: AppStore

    static var appStore = #URL(
        "https://apps.apple.com/app/id1534655259"
    )

    // MARK: Welcome

    static var termsOfServiceURL = #URL(
        "https://flipp.dev/flipper-app-terms-of-service"
    )

    static var privacyPolicyURL = #URL(
        "https://flipp.dev/flipper-app-privacy-policy"
    )

    // MARK: Help

    static var helpToKnowName = #URL(
        "https://flipp.dev/passport"
    )

    static var helpToTurnOnBluetooth = #URL(
        "https://flipp.dev/bluetooth-on"
    )

    static var helpToInstallFirmware = #URL(
        "https://flipp.dev/firmware-update"
    )

    static var helpToReboot = #URL(
        "https://flipp.dev/reboot"
    )

    static var helpToFactoryReset = #URL(
        "https://flipp.dev/storage-repair"
    )

    // MARK: Resources

    static var forum = #URL(
        "https://forum.flipperzero.one"
    )

    static var github = #URL(
        "https://github.com/flipperdevices"
    )

    static var bugReport = #URL(
        "https://flipp.dev/mobile-app-bug-report"
    )
}
