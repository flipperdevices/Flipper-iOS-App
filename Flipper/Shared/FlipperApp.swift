import UI
import Core
import SwiftUI

@main
struct FlipperApp: App {
    init() {
        #if !DEBUG
        Core.migration()
        #endif

        Core.registerMobileDependencies()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
