import Analytics

import Combine
import Logging
import Foundation

@MainActor
public class Router: ObservableObject {
    @Published public private(set) var isFirstLaunch: Bool {
        didSet { UserDefaultsStorage.shared.isFirstLaunch = isFirstLaunch }
    }

    public init() {
        isFirstLaunch = UserDefaultsStorage.shared.isFirstLaunch
    }

    public func showWelcomeScreen() {
        isFirstLaunch = true
    }

    public func hideWelcomeScreen() {
        isFirstLaunch = false
    }

    public func recordAppOpen() {
        analytics.appOpen(target: .app)
    }
}
