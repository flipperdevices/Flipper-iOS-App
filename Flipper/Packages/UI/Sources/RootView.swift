import Core
import SwiftUI

public struct RootView: View {
    @StateObject var dependencies: Dependencies = .shared

    public init() {}

    public var body: some View {
        RootViewImpl()
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

    @StateObject var alertController: AlertController = .init()
    @StateObject var hexKeyboardController: HexKeyboardController = .init()

    @Environment(\.scenePhase) var scenePhase
    @Environment(\.isPresented) var isPresented

    @State private var isPairingIssue = false
    @State private var isUpdateAvailable = false

    init() {}

    var body: some View {
        ZStack {
            ZStack {
                if router.isFirstLaunch {
                    WelcomeView()
                } else {
                    MainView()
                }
            }
            .animation(.linear, value: router.isFirstLaunch)
            .transition(.opacity)

            VStack {
                Spacer()
                HexKeyboard(
                    onButton: { hexKeyboardController.onKey(.hex($0)) },
                    onBack: { hexKeyboardController.onKey(.back) },
                    onOK: { hexKeyboardController.onKey(.ok) }
                )
                .offset(y: hexKeyboardController.isHidden ? 500 : 0)
            }

            if alertController.isPresented {
                alertController.alert
            }
        }
        .customAlert(isPresented: $isPairingIssue) {
            PairingIssueAlert(isPresented: $isPairingIssue)
        }
        .customAlert(isPresented: $isUpdateAvailable) {
            MobileUpdateAlert(isPresented: $isUpdateAvailable)
        }
        .environmentObject(alertController)
        .environmentObject(hexKeyboardController)
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
