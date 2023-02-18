import UI
import Core
import SwiftUI

@main
struct FlipperApp: App {
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
