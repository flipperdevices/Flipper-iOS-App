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
}
