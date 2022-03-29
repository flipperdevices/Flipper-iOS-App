import Peripheral

class PlainDeviceStorage: DeviceStorage {
    let storage: FileStorage = .init()
    let filename = "device.txt"
    var path: Path { .init(string: filename) }

    var flipper: Flipper? {
        get {
            try? storage.read(path)
        }
        set {
            if let newValue = newValue {
                try? storage.write(newValue, at: path)
            } else {
                try? storage.delete(path)
            }
        }
    }
}
