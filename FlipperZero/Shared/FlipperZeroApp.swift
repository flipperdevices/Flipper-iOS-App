import UI
import Core
import SwiftUI

@main
struct FlipperZeroApp: App {
    init() {
        #if !targetEnvironment(simulator)
        Core.registerDependencies()
        #else
        Core.registerMockDependencies()
        #endif
    }

    var body: some Scene {
        WindowGroup {
            RootView(viewModel: .init())
        }
    }
}
