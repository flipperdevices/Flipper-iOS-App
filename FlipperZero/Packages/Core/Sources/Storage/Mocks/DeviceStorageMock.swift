public class DeviceStorageMock: DeviceStorage {
    let storage = JSONStorage<Peripheral>(
        for: Peripheral.self,
        filename: "periperal.json")

    public var pairedDevice: Peripheral? {
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
