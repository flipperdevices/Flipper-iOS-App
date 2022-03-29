public class DeviceStorageMock: DeviceStorage {
    let storage = JSONStorage<Flipper>(
        for: Flipper.self,
        filename: "periperal.json")

    public var flipper: Flipper? {
        get {
            storage.read()
        }
        set {
            if let value = newValue {
                storage.write(value)
            } else {
                storage.delete()
            }
        }
    }
}
