import Core
import Inject
import Analytics
import Peripheral
import Foundation
import SwiftUI
import Logging

public class RootViewModel: ObservableObject {
    private let logger = Logger(label: "root")

    @Inject private var rpc: RPC
    @Inject private var appState: AppState
    @Inject var analytics: Analytics

    var disposeBag: DisposeBag = .init()

    @Published var isFirstLaunch = true
    @Published var isPairingIssue = false

    public init() {
        recordAppOpen()

        isFirstLaunch = appState.firstLaunch.isFirstLaunch

        appState.$status
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self else { return }
                if $0 == .invalidPairing {
                    self.isPairingIssue = true
                }
                if $0 == .connected || $0 == .unsupportedDevice {
                    self.appState.firstLaunch.hideWelcomeScreen()
                }
            }
            .store(in: &disposeBag)

        appState.firstLaunch.$isFirstLaunch
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isFirstLaunch in
                guard let self else { return }
                if self.isFirstLaunch != isFirstLaunch {
                    withAnimation {
                        self.isFirstLaunch = isFirstLaunch
                    }
                }
            }
            .store(in: &disposeBag)
    }

    func skipConnection() {
        appState.skipPairing()
    }

    func onOpenURL(_ url: URL) {
        Task {
            await appState.onOpenURL(url)
        }
    }

    func playAlert() {
        Task {
            do {
                try await rpc.playAlert()
            } catch {
                logger.error("play alert intent: \(error)")
            }
        }
    }

    var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid

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

    // Analytics

    func recordAppOpen() {
        analytics.appOpen(target: .app)
    }
}
