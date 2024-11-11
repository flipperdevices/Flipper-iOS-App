import Combine

@MainActor
public class Router: ObservableObject {
    @Published public private(set) var isFirstLaunch: Bool {
        didSet { UserDefaultsStorage.shared.isFirstLaunch = isFirstLaunch }
    }

    public var showApps: PassthroughSubject<Void, Never> = .init()

    public init() {
        isFirstLaunch = UserDefaultsStorage.shared.isFirstLaunch

        // TODO: Find better way
        if isFirstLaunch {
            UserDefaultsStorage.shared.showInfraredRemoteTab = false
        }
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
