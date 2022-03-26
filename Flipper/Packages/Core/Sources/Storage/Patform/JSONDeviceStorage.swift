class JSONDeviceStorage: DeviceStorage {
    let storage: JSONStorage<Flipper>

    var flipper: Flipper? {
        get { read() }
        set { write(newValue) }
    }

    init() {
        storage = .init(for: Flipper.self, filename: "paired_device")
    }

    func read() -> Flipper? {
        storage.read()
    }

    func write(_ flipper: Flipper?) {
        if let flipper = flipper {
            storage.write(flipper)
        } else {
            storage.delete()
        }
    }
}
