import Core
import SwiftUI

public struct RootView: View {
    @StateObject var dependencies: Dependencies = .init()

    public init() {}

    public var body: some View {
        RootViewImpl()
            .environmentObject(dependencies.router)
            .environmentObject(dependencies.device)
            .environmentObject(dependencies.central)
            .environmentObject(dependencies.networkMonitor)
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
    @EnvironmentObject var router: Router
    @EnvironmentObject var device: Device

    @StateObject var alertController: AlertController = .init()
    @StateObject var hexKeyboardController: HexKeyboardController = .init()

    @Environment(\.scenePhase) var scenePhase
    @Environment(\.isPresented) var isPresented

    @State private var isPairingIssue = false

    @State private var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid
    @State private var backgroundTask: Task<Void, Swift.Error>?

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
        .onChange(of: scenePhase) { scenePhase in
            switch scenePhase {
            case .active: onActive()
            case .inactive: onInactive()
            default: break
            }
        }
        .onChange(of: isPresented) { isPresented in
            if isPresented {
                router.recordAppOpen()
            }
        }
    }

    func onActive() {
        guard backgroundTaskID != .invalid else {
            return
        }
        endBackgroundTask()
        backgroundTask?.cancel()
        if device.status == .disconnected {
            device.connect()
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
                device.disconnect()
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
