import Peripheral

class PlainDeviceStorage: DeviceStorage {
    let storage: FileStorage = .init()
    let filename = "device.txt"
    var path: Path { .init(string: filename) }

    var flipper: Flipper? {
        get {
            SyncTask { [self] in
                try? await storage.read(path)
            }.get()
        }
        set {
            Task {
                if let newValue = newValue {
                    try? await storage.write(newValue, at: path)
                } else {
                    try? await storage.delete(path)
                }
            }
        }
    }
}
