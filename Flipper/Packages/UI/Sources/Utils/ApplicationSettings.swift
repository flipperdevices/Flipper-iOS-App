#if os(iOS)
import UIKit
#endif

public enum Application {
    public static func openSettings() {
        #if os(iOS)
        if let appSettings = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
        }
        #endif
    }

    public static func openSystemSettings() {
        #if os(iOS)
        if let settings = URL(string: "App-Prefs:root=") {
            UIApplication.shared.open(settings, options: [:], completionHandler: nil)
        }
        #endif
    }
}
