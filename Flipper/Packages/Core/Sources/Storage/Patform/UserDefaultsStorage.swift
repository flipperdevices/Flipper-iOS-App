import Foundation

public class UserDefaultsStorage {
    public static let shared: UserDefaultsStorage = .init()
    private var storage: UserDefaults { .standard }

    public var isFirstLaunch: Bool {
        get { storage.value(forKey: .isFirstLaunchKey) as? Bool ?? true }
        set { storage.set(newValue, forKey: .isFirstLaunchKey) }
    }

    public var selectedTab: String {
        get { storage.value(forKey: .selectedTabKey) as? String ?? "" }
        set { storage.set(newValue, forKey: .selectedTabKey) }
    }

    func reset() {
        storage.removeObject(forKey: .isFirstLaunchKey)
        storage.removeObject(forKey: .selectedTabKey)
    }
}

public extension String {
    static var isFirstLaunchKey: String { "isFirstLaunch" }
    static var selectedTabKey: String { "selectedTab" }
}
