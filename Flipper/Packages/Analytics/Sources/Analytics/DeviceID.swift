import Foundation

public class UserDefaultsStorage {
    public static let shared: UserDefaultsStorage = .init()
    private var storage: UserDefaults { .standard }

    public var deviceID: String {
        if let id = storage.value(forKey: .deviceIDKey) as? String {
            return id
        } else {
            let id = UUID().uuidString
            storage.set(id, forKey: .deviceIDKey)
            return id
        }
    }
}

public extension String {
    static var deviceIDKey: String { "deviceID" }
}
