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
        Core.registerMobileDependencies()
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
