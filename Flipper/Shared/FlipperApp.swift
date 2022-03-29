import UI
import Core
import SwiftUI

@main
struct FlipperApp: App {
    init() {
        #if !DEBUG
        Core.migration()
        #endif

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
