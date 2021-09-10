import Foundation
import CoreBluetooth

class BluetoothService: NSObject, BluetoothCentral, BluetoothConnector {
    private let manager: CBCentralManager

    private var flipperServiceIDs: [CBUUID] {
        [.flipperZeroWhite, .flipperZeroBlack]
    }

    override init() {
        self.manager = CBCentralManager()
        super.init()
        self.manager.delegate = self
    }

    // MARK: BluetoothCentral

    private let statusSubject = SafeSubject(BluetoothStatus.notReady(.preparing))
    private let peripheralsSubject = SafeSubject([Peripheral]())

    var status: SafePublisher<BluetoothStatus> {
        self.statusSubject.eraseToAnyPublisher()
    }

    var peripherals: SafePublisher<[Peripheral]> {
        self.peripheralsSubject.eraseToAnyPublisher()
    }

    private var peripheralsMap = [UUID: CBPeripheral]() {
        didSet { publishPeripherals() }
    }

    private func publishPeripherals() {
        peripheralsSubject.value = peripheralsMap.values
            .compactMap(Peripheral.init)
            .sorted { $0.name < $1.name }
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

    // MARK: BluetoothConnector

    private let connectedPeripheralsSubject = SafeSubject([Peripheral]())

    var connectedPeripherals: SafePublisher<[Peripheral]> {
        self.connectedPeripheralsSubject.eraseToAnyPublisher()
    }

    private var connectedPeripheralsMap = [UUID: CBPeripheral]() {
        didSet { publishConnectedPeripherals() }
    }

    private func publishConnectedPeripherals() {
        connectedPeripheralsSubject.value = connectedPeripheralsMap.values
            .compactMap(Peripheral.init)
            .sorted { $0.name < $1.name }
    }

    func connect(to identifier: UUID) {
        manager.retrievePeripherals(withIdentifiers: [identifier]).forEach {
            manager.connect($0)
            connectedPeripheralsMap[$0.identifier] = $0
        }
    }

    func disconnect(from identifier: UUID) {
        manager.retrievePeripherals(withIdentifiers: [identifier]).forEach {
            manager.cancelPeripheralConnection($0)
            connectedPeripheralsMap[$0.identifier] = nil
        }
    }

    // TODO: Move to separate protocol

    private let receivedSubject = SafeSubject([UInt8]())

    var received: SafePublisher<[UInt8]> {
        receivedSubject.eraseToAnyPublisher()
    }

    func send(_ bytes: [UInt8], to identifier: UUID) {
        guard let connected = connectedPeripheralsMap[identifier] else {
            print("device disconnected")
            return
        }
        guard let tx = connected.serialWrite else {
            print("no serial service")
            return
        }
        connected.writeValue(.init(bytes), for: tx, type: .withResponse)
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
        peripheral.delegate = self
        connectedPeripheralsMap[peripheral.identifier] = peripheral
        peripheral.discoverServices(nil)
    }

    func centralManager(
        _ central: CBCentralManager,
        didDisconnectPeripheral peripheral: CBPeripheral,
        error: Error?
    ) {
        // notify disconnected state
        connectedPeripheralsMap[peripheral.identifier] = peripheral
        connectedPeripheralsMap[peripheral.identifier] = nil
    }

    func centralManager(
        _ central: CBCentralManager,
        didFailToConnect peripheral: CBPeripheral,
        error: Error?
    ) {
        connectedPeripheralsMap[peripheral.identifier] = nil
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
            switch service.uuid {
            case .serial:
                // subscribe to rx updates
                if characteristic.properties.contains(.indicate) {
                    peripheral.setNotifyValue(true, for: characteristic)
                }
            default:
                // subscibe to value updates
                if characteristic.properties.contains(.notify) {
                    peripheral.setNotifyValue(true, for: characteristic)
                }
                // read the value
                peripheral.readValue(for: characteristic)
            }
        }
    }

    // MARK: Values

    public func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateValueFor characteristic: CBCharacteristic,
        error: Error?
    ) {
        if characteristic.uuid == .serialRead {
            receivedSubject.value = .init((characteristic.value ?? .init()))
        } else {
            publishConnectedPeripherals()
        }
    }
}

fileprivate extension CBPeripheral {
    var serialWrite: CBCharacteristic? {
        services?
            .first { $0.uuid == .serial }?
            .characteristics?
            .first { $0.uuid == .serialWrite }
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
        guard var name = source.name, name.starts(with: "Flipper ") else {
            return nil
        }
        name = String(name.dropFirst("Flipper ".count))

        self.id = source.identifier
        self.name = name
        self.state = .init(source.state)

        self.deviceInformation = source.services?
            .first { $0.uuid == .deviceInformation }
            .map(Service.DeviceInformation.init) ?? nil

        self.battery = source.services?
            .first { $0.uuid == .battery }
            .map(Service.Battery.init) ?? nil
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

fileprivate extension Peripheral.Service.DeviceInformation {
    init?(_ source: CBService) {
        guard source.uuid == .deviceInformation else { return nil }
        self.init(manufacturerName: "", serialNumber: "", firmwareRevision: "", softwareRevision: "")
        source.characteristics?.forEach {
            switch $0.uuid.description.dropLast(" String".count) {
            case manufacturerName.name: self.manufacturerName.value = parse($0.value)
            case serialNumber.name: self.serialNumber.value = parse($0.value)
            case firmwareRevision.name: self.firmwareRevision.value = parse($0.value)
            case softwareRevision.name: self.softwareRevision.value = parse($0.value)
            default: return
            }
        }
    }

    private func parse(_ data: Data?) -> String {
        guard let data = data else { return "" }
        return String(data: data, encoding: .utf8) ?? ""
    }
}

fileprivate extension Peripheral.Service.Battery {
    init?(_ source: CBService) {
        guard
            source.uuid == .battery,
            let level = source.characteristics?.first,
            let data = level.value, data.count == 1
        else {
            return nil
        }
        self.init(level: Int(data[0]))
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
        self.name = source.uuid.description
        switch source.value {
        case let .some(data):
            self.value = String(data: data, encoding: .utf8) ?? ""
        case .none:
            self.value = ""
        }
    }
}

extension CBUUID {
    static var flipperZeroWhite: CBUUID { .init(string: "3080") }
    static var flipperZeroBlack: CBUUID { .init(string: "3081") }

    static var deviceInformation: CBUUID { .init(string: "180A") }
    static var battery: CBUUID { .init(string: "180F") }
    static var batteryLevel: CBUUID { .init(string: "2A19") }

    static var serial: CBUUID { .init(string: "8FE5B3D5-2E7F-4A98-2A48-7ACC60FE0000") }
    static var serialRead: CBUUID { .init(string: "19ED82AE-ED21-4C9D-4145-228E61FE0000") }
    static var serialWrite: CBUUID { .init(string: "19ED82AE-ED21-4C9D-4145-228E62FE0000") }
}
