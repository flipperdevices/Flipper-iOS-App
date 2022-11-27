import Combine

public class FirstLaunch: ObservableObject {
    public static let shared = FirstLaunch()

    @Published public private(set) var isFirstLaunch: Bool {
        didSet { UserDefaultsStorage.shared.isFirstLaunch = isFirstLaunch }
    }

    private init() {
        isFirstLaunch = UserDefaultsStorage.shared.isFirstLaunch
    }

    public func showWelcomeScreen() {
        isFirstLaunch = true
    }

    public func hideWelcomeScreen() {
        isFirstLaunch = false
    }
}
