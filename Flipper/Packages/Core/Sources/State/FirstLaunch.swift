import Combine

struct FirstLaunch {
    var isFirstLaunch: Bool {
        didSet { UserDefaultsStorage.shared.isFirstLaunch = isFirstLaunch }
    }

    init() {
        isFirstLaunch = UserDefaultsStorage.shared.isFirstLaunch
    }

    mutating func showWelcomeScreen() {
        isFirstLaunch = true
    }

    mutating func hideWelcomeScreen() {
        isFirstLaunch = false
    }
}
