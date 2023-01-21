import Core
import SwiftUI

public struct RootView: View {
    @StateObject var dependencies: Depencencies = .init()

    public init() {}

    public var body: some View {
        RootViewImpl()
            .environmentObject(dependencies.appState)
            .environmentObject(dependencies.applicationService)
            .environmentObject(dependencies.loggerService)
            .environmentObject(dependencies.networkService)
            .environmentObject(dependencies.centralService)
            .environmentObject(dependencies.flipperService)
            .environmentObject(dependencies.archiveService)
            .environmentObject(dependencies.syncService)
            .environmentObject(dependencies.updateService)
            .environmentObject(dependencies.checkUpdateService)
            .environmentObject(dependencies.sharingService)
            .environmentObject(dependencies.emulateService)
            .environmentObject(dependencies.widgetService)
    }
}

private struct RootViewImpl: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var applicationService: ApplicationService
    @EnvironmentObject var flipperService: FlipperService

    @StateObject var alertController: AlertController = .init()
    @StateObject var hexKeyboardController: HexKeyboardController = .init()

    @Environment(\.scenePhase) var scenePhase

    @State private var isPairingIssue = false

    @State private var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid
    @State private var backgroundTask: Task<Void, Swift.Error>?

    init() {}

    var body: some View {
        ZStack {
            ZStack {
                if applicationService.isFirstLanuch {
                    WelcomeView()
                } else {
                    MainView()
                }
            }
            .animation(.linear, value: applicationService.isFirstLanuch)
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
        .onContinueUserActivity("PlayAlertIntent") { _ in
            flipperService.playAlert()
        }
        .onChange(of: appState.status) {
            if $0 == .invalidPairing {
                isPairingIssue = true
            }
            if $0 == .connected || $0 == .unsupported {
                applicationService.hideWelcomeScreen()
            }
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .active: onActive()
            case .inactive: onInactive()
            default: break
            }
        }
    }

    func onActive() {
        guard backgroundTaskID != .invalid else {
            return
        }
        endBackgroundTask()
        backgroundTask?.cancel()
        applicationService.recordAppOpen()
        if appState.status == .disconnected {
            flipperService.connect()
        }
    }

    func onInactive() {
        guard backgroundTaskID == .invalid else {
            return
        }
        Task {
            backgroundTaskID = startBackgroundTask()
            backgroundTask = Task {
                try await Task.sleep(seconds: 3)
                //logger.info("disconnecting due to inactivity")
                flipperService.disconnect()
            }
            _ = await backgroundTask?.result
            backgroundTask = nil
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
}
