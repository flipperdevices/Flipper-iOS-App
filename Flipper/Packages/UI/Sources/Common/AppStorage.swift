import Core
import SwiftUI

extension AppStorage {
    public init(
        wrappedValue: Value,
        _ key: UserDefaults.Keys,
        store: UserDefaults? = nil
    ) where Value == Bool {
        self.init(wrappedValue: wrappedValue, key.rawValue, store: store)
    }

    public init(
        wrappedValue: Value,
        _ key: UserDefaults.Keys,
        store: UserDefaults? = nil
    ) where Value == Int {
        self.init(wrappedValue: wrappedValue, key.rawValue, store: store)
    }

    public init(
        wrappedValue: Value,
        _ key: UserDefaults.Keys,
        store: UserDefaults? = nil
    ) where Value == Double {
        self.init(wrappedValue: wrappedValue, key.rawValue, store: store)
    }

    public init(
        wrappedValue: Value,
        _ key: UserDefaults.Keys,
        store: UserDefaults? = nil
    ) where Value == String {
        self.init(wrappedValue: wrappedValue, key.rawValue, store: store)
    }

    public init(
        wrappedValue: Value,
        _ key: UserDefaults.Keys,
        store: UserDefaults? = nil
    ) where Value == URL {
        self.init(wrappedValue: wrappedValue, key.rawValue, store: store)
    }

    public init(
        wrappedValue: Value,
        _ key: UserDefaults.Keys,
        store: UserDefaults? = nil
    ) where Value == Data {
        self.init(wrappedValue: wrappedValue, key.rawValue, store: store)
    }

    public init(
        wrappedValue: Value,
        _ key: UserDefaults.Keys,
        store: UserDefaults? = nil
    ) where Value: RawRepresentable, Value.RawValue == Int {
        self.init(wrappedValue: wrappedValue, key.rawValue, store: store)
    }

    public init(
        wrappedValue: Value,
        _ key: UserDefaults.Keys,
        store: UserDefaults? = nil
    ) where Value: RawRepresentable, Value.RawValue == String {
        self.init(wrappedValue: wrappedValue, key.rawValue, store: store)
    }
}
