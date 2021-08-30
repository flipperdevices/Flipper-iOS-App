import CoreBluetooth

class BluetoothService: NSObject, BluetoothConnector {
    private let manager: CBCentralManager

    // FIXME: The only CBUUID Flipper advertise
    private var flipperServiceIDs: [CBUUID] { [.heartRate] }

    private let peripheralsSubject = SafeSubject([Peripheral]())
    private let connectedPeripheralSubject = SafeSubject(Peripheral?.none)
    private let statusSubject = SafeSubject(BluetoothStatus.notReady(.preparing))

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
        peripheralsSubject.value = []
        let connected = manager.retrieveConnectedPeripherals(withServices: flipperServiceIDs)
        let discovered = peripheralsMap.values.filter { !connected.contains($0) }
        peripheralsSubject.value = (connected + discovered)
            .compactMap(Peripheral.init)
            .sorted { $0.name < $1.name }
    }

    private func publishConnectedPeripheral() {
        if let connected = connectedCBPeripheral {
            connectedPeripheralSubject.value = Peripheral(connected)
        } else {
            connectedPeripheralSubject.value = .none
        }
    }

    var status: SafePublisher<BluetoothStatus> {
        self.statusSubject.eraseToAnyPublisher()
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
        guard let peripheral = peripheralsMap[uuid] else {
            return
        }
        manager.connect(peripheral)
        publishPeripherals()
    }
}

extension BluetoothService: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ manager: CBCentralManager) {
        let status = BluetoothStatus(manager.state)
        self.statusSubject.value = status
        if status != .ready {
            self.peripheralsMap.removeAll()
        }
    }

    func centralManager(
        _: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi: NSNumber
    ) {
        if self.peripheralsMap[peripheral.identifier] == nil,
            let isConnectable = advertisementData[CBAdvertisementDataIsConnectable] as? Bool,
            isConnectable {

            self.peripheralsMap[peripheral.identifier] = peripheral
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if let connected = connectedCBPeripheral {
            print("disconnecting from", connected.name ?? "<unknown>")
            central.cancelPeripheralConnection(connected)
        }
        print("connected to \(peripheral)")
        peripheral.delegate = self
        connectedCBPeripheral = peripheral
        publishPeripherals()
        publishConnectedPeripheral()

        peripheral.discoverServices(nil)
    }

    // TODO: handle connection failure
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("did fail to connect to \(peripheral)")
        if let error = error {
            print(error)
        }
        publishPeripherals()
        publishConnectedPeripheral()
    }
}

extension BluetoothService: CBPeripheralDelegate {

    // MARK: RSSI

    public func peripheralDidUpdateRSSI(
        _ peripheral: CBPeripheral,
        error: Error?
    ) {
        print("rssi updated")
    }

    public func peripheral(
        _ peripheral: CBPeripheral,
        didReadRSSI RSSI: NSNumber,
        error: Error?
    ) {
        print("new rssi:", RSSI)
    }

    // MARK: Services

    public func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverServices error: Error?
    ) {
        peripheral.services?.forEach { service in
            print("service discovered", service.uuid.uuidString)
            guard service.uuid != .heartRate else {
                return
            }
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    // MARK: Characteristics

    public func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverCharacteristicsFor service: CBService,
        error: Error?
    ) {
        guard let characteristics = service.characteristics else {
            print("no characteristic discovered")
            return
        }
        print("\(characteristics.count) characteristics discovered for service:", service.uuid)
        characteristics.forEach { characteristic in
            peripheral.readValue(for: characteristic)
        }
    }

    // MARK: Values

    public func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateValueFor characteristic: CBCharacteristic,
        error: Error?
    ) {
        print("new value for:", characteristic.uuid)
        // let characteristic = Characteristic(characteristic)
        publishConnectedPeripheral()
    }
    public func peripheral(
        _ peripheral: CBPeripheral,
        didWriteValueFor characteristic: CBCharacteristic,
        error: Error?
    ) {
        print("value written for:", characteristic.uuid)
    }
    public func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateNotificationStateFor characteristic: CBCharacteristic,
        error: Error?
    ) {
        print("notification state has changed to:", characteristic.isNotifying)
    }
    public func peripheralIsReady(
        toSendWriteWithoutResponse peripheral: CBPeripheral
    ) {
        print("toSendWriteWithoutResponse")
    }
    public func peripheral(
        _ peripheral: CBPeripheral,
        didOpen channel: CBL2CAPChannel?,
        error: Error?
    ) {
        print("L2CAP channel:", channel?.description ?? "nil")
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
        guard let name = source.name else {
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
        switch source.service?.uuid {
        case .some(.heartRate):
            self.value = String(format: "%02hhx", [UInt8](data))
        case .some(.deviceInformation):
            self.value = String(data: data.dropLast(), encoding: .utf8) ?? ""
        default:
            self.value = "<unsupported>"
        }
    }
}

extension CBUUID {
    static var deviceInformation: CBUUID { .init(string: "180A") }
    static var heartRate: CBUUID { .init(string: "180D") }
    static var battery: CBUUID { .init(string: "180F") }
    static var continuity: CBUUID { .init(string: "D0611E78-BBB4-4591-A5F8-487910AE4366") }
    static var appleWatch: CBUUID { .init(string: "9FA480E0-4967-4542-9390-D343DC5D04AE") }
    static var service1: CBUUID { .init(string: "be7a721c-34f4-8733-faa2-29d4ae017fcc") }
}
