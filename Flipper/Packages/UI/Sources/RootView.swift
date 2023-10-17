import Core
import SwiftUI

public struct RootView: View {
    @StateObject var dependencies: Dependencies = .shared

    public init() {}

    public var body: some View {
        AlertStack {
            RootViewImpl()
        }
        .environmentObject(dependencies.router)
        .environmentObject(dependencies.device)
        .environmentObject(dependencies.central)
        .environmentObject(dependencies.networkMonitor)
        .environmentObject(dependencies.archiveModel)
        .environmentObject(dependencies.synchronization)
        .environmentObject(dependencies.updateModel)
        .environmentObject(dependencies.sharing)
        .environmentObject(dependencies.emulate)
        .environmentObject(dependencies.applications)
    }
}

private struct RootViewImpl: View {
    @EnvironmentObject var router: Router
    @EnvironmentObject var device: Device

    @Environment(\.scenePhase) var scenePhase
    @Environment(\.isPresented) var isPresented

    @State private var isPairingIssue = false
    @State private var isUpdateAvailable = false

    init() {}

    var body: some View {
        Group {
            ZStack {
                if router.isFirstLaunch {
                    WelcomeView()
                } else {
                    MainView()
                }
            }
            .animation(.linear, value: router.isFirstLaunch)
            .transition(.opacity)
        }
        .customAlert(isPresented: $isPairingIssue) {
            PairingIssueAlert(isPresented: $isPairingIssue)
        }
        .customAlert(isPresented: $isUpdateAvailable) {
            MobileUpdateAlert(isPresented: $isUpdateAvailable)
        }
        .onContinueUserActivity("PlayAlertIntent") { _ in
            device.playAlert()
        }
        .onChange(of: device.status) {
            if $0 == .invalidPairing {
                isPairingIssue = true
            }
            if $0 == .connected || $0 == .unsupported {
                router.hideWelcomeScreen()
            }
        }
        .task {
            router.recordAppOpen()
            isUpdateAvailable = await AppVersionCheck.hasUpdate
        }
    }
}
