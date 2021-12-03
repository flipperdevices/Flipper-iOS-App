import UI
import Core
import Mock
import SwiftUI

@main
struct FlipperZeroApp: App {
    init() {
        #if !targetEnvironment(simulator)
        Core.registerDependencies()
        #else
        Mock.registerMockDependencies()
        #endif
    }

    var body: some Scene {
        WindowGroup {
            RootView(viewModel: .init())
        }
    }
}
