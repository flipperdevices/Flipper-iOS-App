import Foundation

class UserDefaultsStorage: LocalStorage {
    var storage: UserDefaults { .standard }

    let lastDeviceKey: String = "lastConnectedDeviceUUIDString"

    var lastConnectedDevice: UUID? {
        get {
            guard
                let value = storage.value(forKey: lastDeviceKey) as? String,
                let uuid = UUID(uuidString: value)
            else {
                return nil
            }
            return uuid
        }

        set {
            switch newValue {
            case let .some(uuid):
                storage.set(uuid.uuidString, forKey: lastDeviceKey)
            case .none:
                storage.removeObject(forKey: lastDeviceKey)
            }
        }
    }
}
