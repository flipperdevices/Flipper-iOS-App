import Core
import Inject
import SwiftUI

public struct RootView: View {
    @StateObject var dependencies: Depencencies = .init()

    public init() {}

    public var body: some View {
        RootViewImpl()
            .environmentObject(dependencies.appState)
            .environmentObject(dependencies.loggerService)
            .environmentObject(dependencies.networkService)
            .environmentObject(dependencies.centralService)
            .environmentObject(dependencies.flipperService)
            .environmentObject(dependencies.archiveService)
            .environmentObject(dependencies.updateService)
            .environmentObject(dependencies.emulateService)
            .environmentObject(dependencies.widgetService)
    }
}

private struct RootViewImpl: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var flipperService: FlipperService

    @StateObject var alertController: AlertController = .init()
    @StateObject var hexKeyboardController: HexKeyboardController = .init()

    @Environment(\.scenePhase) var scenePhase

    @State var isFirstLaunch = false
    @State var isPairingIssue = false

    @State var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid

    init() {}

    var body: some View {
        ZStack {
            ZStack {
                if appState.firstLaunch.isFirstLaunch {
                    WelcomeView()
                } else {
                    MainView()
                }
            }
            .animation(.linear, value: appState.firstLaunch.isFirstLaunch)
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
        .environmentObject(alertController)
        .environmentObject(hexKeyboardController)
        .onOpenURL { url in
            appState.onOpenURL(url)
        }
        .onContinueUserActivity("PlayAlertIntent") { _ in
            flipperService.playAlert()
        }
        .onChange(of: appState.status) {
            if $0 == .invalidPairing {
                isPairingIssue = true
            }
            if $0 == .connected || $0 == .unsupportedDevice {
                appState.firstLaunch.hideWelcomeScreen()
            }
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .active: onActive()
            case .inactive: onInactive()
            default: break
            }
        }
        .onAppear {
            recordAppOpen()
        }
    }

    func onActive() {
        guard backgroundTaskID != .invalid else {
            return
        }
        endBackgroundTask()
        appState.onActive()
    }

    func onInactive() {
        guard backgroundTaskID == .invalid else {
            return
        }
        Task {
            backgroundTaskID = startBackgroundTask()
            try await appState.onInactive()
            endBackgroundTask()
        }
    }

    private func startBackgroundTask() -> UIBackgroundTaskIdentifier {
        UIApplication.shared.beginBackgroundTask {
            self.endBackgroundTask()
        }
    }

    private func endBackgroundTask() {
        UIApplication.shared.endBackgroundTask(backgroundTaskID)
        backgroundTaskID = .invalid
    }

    // MARK: Analytics

    func recordAppOpen() {
        appState.analytics.appOpen(target: .app)
    }
}
