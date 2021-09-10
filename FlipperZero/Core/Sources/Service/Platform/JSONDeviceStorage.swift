class JSONDeviceStorage: DeviceStorage {
    let storage: JSONStorage<Peripheral>

    var pairedDevice: Peripheral? {
        get { read() }
        set { write(newValue) }
    }

    init() {
        storage = .init(for: Peripheral.self, filename: "paired_device")
    }

    func migrate() -> Peripheral? {
        guard let uuid = UserDefaultsStorage().lastConnectedDevice else {
            return nil
        }
        UserDefaultsStorage().lastConnectedDevice = nil
        return Peripheral(id: uuid, name: "Unknown")
    }

    func read() -> Peripheral? {
        if let peripheral = migrate() {
            return peripheral
        }
        return storage.read()
    }

    func write(_ peripheral: Peripheral?) {
        if let peripheral = peripheral {
            storage.write(peripheral)
        } else {
            storage.delete()
        }
    }
}
