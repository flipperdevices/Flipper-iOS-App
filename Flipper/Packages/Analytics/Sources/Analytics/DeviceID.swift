import Foundation

public enum DeviceID {
    private static var storage: UserDefaults { .standard }

    public static var uuidString: String {
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
