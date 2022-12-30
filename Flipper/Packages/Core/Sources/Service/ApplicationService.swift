import Inject
import Analytics

import Combine
import Logging
import Foundation

@MainActor
public class ApplicationService: ObservableObject {
    private let logger = Logger(label: "application-service")

    let appState: AppState
    let flipperService: FlipperService

    @Inject var analytics: Analytics
    private var disposeBag: DisposeBag = .init()

    public init(appState: AppState, flipperService: FlipperService) {
        self.appState = appState
        self.flipperService = flipperService
        subscribeToPublishers()
    }

    func subscribeToPublishers() {
    }

    // MARK: Background

    private var backgroundTask: Task<Void, Swift.Error>?

    public func onActive() {
        backgroundTask?.cancel()
        if appState.status == .disconnected {
            flipperService.connect()
        }
        recordAppOpen()
    }

    public func onInactive() async throws {
        backgroundTask = Task {
            try await Task.sleep(minutes: 10)
            logger.info("disconnecting due to inactivity")
            flipperService.disconnect()
        }
        _ = await backgroundTask?.result
        backgroundTask = nil
    }

    // MARK: App Reset

    public func reset() {
        AppReset().reset()
    }

    // MARK: Analytics

    func recordAppOpen() {
        analytics.appOpen(target: .app)
    }
}
