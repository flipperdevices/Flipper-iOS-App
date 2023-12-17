import UI
import Core
import SwiftUI

@main
struct FlipperApp: App {
    @State var showRootView = false
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    init() {
    }

    var body: some Scene {
        WindowGroup {
            if showRootView {
                RootView()
            } else {
                LaunchScreenView()
                    .task {
                        await Core.migration()
                        showRootView = true
                    }
            }
        }
    }
}
