#if os(iOS)
import UIKit
#endif

public enum Application {
    public static func openSettings() {
        #if os(iOS)
        UIApplication.shared.open(.settings)
        #endif
    }

    public static func openSystemSettings() {
        #if os(iOS)
        UIApplication.shared.open(.systemSettings)
        #endif
    }
}
