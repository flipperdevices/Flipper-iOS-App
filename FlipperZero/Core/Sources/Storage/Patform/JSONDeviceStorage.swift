class JSONDeviceStorage: DeviceStorage {
    let storage: JSONStorage<Peripheral>

    var pairedDevice: Peripheral? {
        get { read() }
        set { write(newValue) }
    }

    init() {
        storage = .init(for: Peripheral.self, filename: "paired_device")
    }

    func read() -> Peripheral? {
        storage.read()
    }

    func write(_ peripheral: Peripheral?) {
        if let peripheral = peripheral {
            storage.write(peripheral)
        } else {
            storage.delete()
        }
    }
}
