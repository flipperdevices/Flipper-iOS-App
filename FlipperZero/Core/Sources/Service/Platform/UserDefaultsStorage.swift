import Foundation

public class UserDefaultsStorage {
    public static let shared: UserDefaultsStorage = .init()
    private var storage: UserDefaults { .standard }

    let isFirstLaunchKey: String = "isFirstLaunch"

    public var isFirstLaunch: Bool {
        get { storage.value(forKey: isFirstLaunchKey) as? Bool ?? true }
        set { storage.set(newValue, forKey: isFirstLaunchKey) }
    }
}
