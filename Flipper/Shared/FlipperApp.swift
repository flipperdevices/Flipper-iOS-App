import UI
import Core
import SwiftUI

@main
struct FlipperApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    init() {
        #if !DEBUG
        Core.migration()
        #endif
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
