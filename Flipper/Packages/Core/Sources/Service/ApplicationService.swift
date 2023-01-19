import Inject
import Analytics

import Combine
import Logging
import Foundation

@MainActor
public class ApplicationService: ObservableObject {
    @Published var firstLaunch: FirstLaunch = .init()

    public var isFirstLanuch: Bool { firstLaunch.isFirstLaunch }

    private var disposeBag: DisposeBag = .init()

    public init() {
        subscribeToPublishers()
    }

    func subscribeToPublishers() {
    }

    // Welcome Screen

    public func showWelcomeScreen() {
        firstLaunch.showWelcomeScreen()
    }

    public func hideWelcomeScreen() {
        firstLaunch.hideWelcomeScreen()
    }

    // MARK: App Reset

    public func reset() {
        AppReset().reset()
    }

    // MARK: Analytics

    public func recordAppOpen() {
        analytics.appOpen(target: .app)
    }
}
