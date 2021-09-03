import CoreBluetooth

class BluetoothService: NSObject, BluetoothConnector {
    private let manager: CBCentralManager

    private var flipperServiceIDs: [CBUUID] { [.flipperZeroWhite, .flipperZeroBlack] }

    private let statusSubject = SafeSubject(BluetoothStatus.notReady(.preparing))
    private let peripheralsSubject = SafeSubject([Peripheral]())
    private let connectedPeripheralSubject = SafeSubject(Peripheral?.none)

    var status: SafePublisher<BluetoothStatus> {
        self.statusSubject.eraseToAnyPublisher()
    }

    var peripherals: SafePublisher<[Peripheral]> {
        self.peripheralsSubject.eraseToAnyPublisher()
    }

    var connectedPeripheral: SafePublisher<Peripheral?> {
        self.connectedPeripheralSubject.eraseToAnyPublisher()
    }

    private var peripheralsMap = [UUID: CBPeripheral]() {
        didSet { publishPeripherals() }
    }

    private var connectedCBPeripheral: CBPeripheral? {
        didSet { publishConnectedPeripheral() }
    }

    private func publishPeripherals() {
        let connected = manager
            .retrieveConnectedPeripherals(withServices: [.deviceInformation])
            .filter { $0.state == .connected }
            .compactMap(Peripheral.init)

        let discovered = peripheralsMap.values
            .compactMap(Peripheral.init)

        peripheralsSubject.value = (connected + discovered)
            .sorted { $0.name < $1.name }
    }

    private func publishConnectedPeripheral() {
        if let connected = connectedCBPeripheral {
            connectedPeripheralSubject.value = Peripheral(connected)
        } else {
            connectedPeripheralSubject.value = .none
        }
    }

    override init() {
        self.manager = CBCentralManager()
        super.init()
        self.manager.delegate = self
    }

    func startScanForPeripherals() {
        if self.statusSubject.value == .ready {
            self.manager.scanForPeripherals(withServices: flipperServiceIDs)
        }
    }

    func stopScanForPeripherals() {
        if self.manager.isScanning {
            self.peripheralsMap.removeAll()
            self.manager.stopScan()
        }
    }

    func connect(to uuid: UUID) {
        manager.retrievePeripherals(withIdentifiers: [uuid]).forEach {
            manager.connect($0)
            peripheralsMap[$0.identifier] = $0
        }
    }

    func forget(about uuid: UUID) {
        manager.retrievePeripherals(withIdentifiers: [uuid]).forEach {
            manager.cancelPeripheralConnection($0)
        }
    }
}

extension BluetoothService: CBCentralManagerDelegate {

    // MARK: Status changed

    func centralManagerDidUpdateState(_ manager: CBCentralManager) {
        if manager.state != .poweredOn {
            self.peripheralsMap.removeAll()
        }
        self.statusSubject.value = .init(manager.state)
    }

    // MARK: Did discover

    func centralManager(
        _: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi: NSNumber
    ) {
        self.peripheralsMap[peripheral.identifier] = peripheral
    }

    // MARK: Connection status changed

    func centralManager(
        _ central: CBCentralManager,
        didConnect peripheral: CBPeripheral
    ) {
        if let connected = connectedCBPeripheral {
            central.cancelPeripheralConnection(connected)
        }
        peripheral.delegate = self
        connectedCBPeripheral = peripheral
        publishConnectedPeripheral()
        publishPeripherals()

        peripheral.discoverServices(nil)
    }

    func centralManager(
        _ central: CBCentralManager,
        didDisconnectPeripheral peripheral: CBPeripheral,
        error: Error?
    ) {
        if connectedCBPeripheral?.identifier == peripheral.identifier {
            connectedCBPeripheral = nil
        }
        publishConnectedPeripheral()
        publishPeripherals()
    }

    func centralManager(
        _ central: CBCentralManager,
        didFailToConnect peripheral: CBPeripheral,
        error: Error?
    ) {
        publishConnectedPeripheral()
        publishPeripherals()
    }
}

// MARK: Peripheral delegate

extension BluetoothService: CBPeripheralDelegate {

    // MARK: Services

    public func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverServices error: Error?
    ) {
        peripheral.services?.forEach { service in
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    // MARK: Characteristics

    public func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverCharacteristicsFor service: CBService,
        error: Error?
    ) {
        service.characteristics?.forEach { characteristic in
            peripheral.readValue(for: characteristic)
        }
    }

    // MARK: Values

    public func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateValueFor characteristic: CBCharacteristic,
        error: Error?
    ) {
        publishConnectedPeripheral()
    }
}

fileprivate extension BluetoothStatus {
    init(_ source: CBManagerState) {
        switch source {
        case .resetting, .unknown:
            self = .notReady(.preparing)
        case .unsupported:
            self = .notReady(.unsupported)
        case .unauthorized:
            self = .notReady(.unauthorized)
        case .poweredOff:
            self = .notReady(.poweredOff)
        case .poweredOn:
            self = .ready
        @unknown default:
            self = .notReady(.unsupported)
        }
    }
}

fileprivate extension Peripheral {
    init?(_ source: CBPeripheral) {
        guard let name = source.name, name.starts(with: "Flipper") else {
            return nil
        }

        self.id = source.identifier
        self.name = name
        self.state = .init(source.state)
        self.services = (source.services ?? [])
            .map(Service.init)
            .filter { $0.name == "Device Information" }
    }
}

fileprivate extension Peripheral.State {
    init(_ source: CBPeripheralState) {
        // swiftlint:disable switch_case_on_newline
        switch source {
        case .disconnected: self = .disconnected
        case .connecting: self = .connecting
        case .connected: self = .connected
        case .disconnecting: self = .disconnecting
        @unknown default: self = .disconnected
        }
    }
}

extension Peripheral.Service {
    init(_ source: CBService) {
        self.name = source.uuid.description
        self.characteristics = source.characteristics?.map(Characteristic.init) ?? []
    }
}

extension Peripheral.Service.Characteristic {
    init(_ source: CBCharacteristic) {
        self.name = .init(source.uuid.description.dropLast(" String".count))
        guard let data = source.value else {
            value = ""
            return
        }

        // FIXME: hack for github actions where source.service is not optional
        func getCBUUID(_ service: CBService?) -> CBUUID? {
            service?.uuid
        }

        switch getCBUUID(source.service) {
        case .some(.deviceInformation):
            self.value = String(data: data.dropLast(), encoding: .utf8) ?? ""
        default:
            self.value = "<unsupported>"
        }
    }
}

extension CBUUID {
    static var flipperZeroWhite: CBUUID { .init(string: "3080") }
    static var flipperZeroBlack: CBUUID { .init(string: "3081") }

    static var deviceInformation: CBUUID { .init(string: "180A") }
    static var battery: CBUUID { .init(string: "180F") }
}
