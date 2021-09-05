import UI
import Core
import SwiftUI

@main
struct FlipperZeroApp: App {
    init() {
        Core.registerDependencies()
        Core.registerMocks()
    }

    var body: some Scene {
        WindowGroup {
            RootView(viewModel: .init())
        }
    }
}
