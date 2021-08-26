import Core
import SwiftUI

@main
struct FlipperZeroApp: App {
    init() {
        Core.registerDependencies()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
