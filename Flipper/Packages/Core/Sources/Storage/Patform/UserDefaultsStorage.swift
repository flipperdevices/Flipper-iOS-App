import Logging
import Foundation

public class UserDefaultsStorage {
    public static let shared: UserDefaultsStorage = .init()
    var storage: UserDefaults { .standard }

    @UserDefault(key: .isFirstLaunch, defaultValue: true)
    public var isFirstLaunch: Bool

    @UserDefault(key: .selectedTab, defaultValue: "")
    public var selectedTab: String

    @UserDefault(key: .updateChannel, defaultValue: .release)
    public var updateChannel: Update.Channel

    @UserDefault(key: .logLevelKey, defaultValue: .debug)
    public var logLevel: Logger.Level

    @UserDefault(key: .hasReaderLog, defaultValue: false)
    public var hasReaderLog: Bool

    // MARK: Debug

    @UserDefault(key: .isDebugMode, defaultValue: false)
    public var isDebugMode: Bool

    @UserDefault(key: .isProvisioningDisabled, defaultValue: false)
    public var isProvisioningDisabled: Bool

    @UserDefault(key: .isDevCatalog, defaultValue: false)
    public var isDevCatalog: Bool

    func reset() {
        UserDefaults.Keys
            .allCases
            .map { $0.rawValue }
            .forEach(storage.removeObject)
    }
}

@propertyWrapper
public struct UserDefault<T> {
    var getter: () -> T
    var setter: (T) -> Void

    public var wrappedValue: T {
        get { getter() }
        set { setter(newValue) }
    }

    init(key: UserDefaults.Keys, defaultValue: T) {
        getter = {
            UserDefaults.standard.object(forKey: key.rawValue) as? T
                ?? defaultValue
        }
        setter = { newValue in
            UserDefaults.standard.set(newValue, forKey: key.rawValue)
        }
    }

    init(key: UserDefaults.Keys, defaultValue: T) where T: RawRepresentable {
        getter = {
            guard
                let value = UserDefaults.standard.object(forKey: key.rawValue)
                    as? T.RawValue
            else {
                return defaultValue
            }
            return T(rawValue: value) ?? defaultValue
        }
        setter = { newValue in
            UserDefaults.standard.set(newValue.rawValue, forKey: key.rawValue)
        }
    }
}

public extension UserDefaults {
    enum Keys: String, CaseIterable {
        case isFirstLaunch = "isFirstLaunch"
        case selectedTab = "selectedTab"
        case notificationsSuggested = "notificationsSuggested"
        case isNotificationsOn = "isNotificationsOn"
        case updateChannel = "updateChannel"
        case installingVersion = "installingVersion"
        case logLevelKey = "logLevel"
        case hasReaderLog = "hasReaderLog"
        case hiddenApps = "hiddenApps"

        case isDebugMode = "isDebugMode"
        case isProvisioningDisabled = "isProvisioningDisabled"
        case isDevCatalog = "isDevCatalog"

        case appsSortOrder = "appsSortOrder"
    }
}
