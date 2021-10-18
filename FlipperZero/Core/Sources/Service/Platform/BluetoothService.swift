import Foundation
import Collections
import CoreBluetooth

class BluetoothService: NSObject, BluetoothCentral, BluetoothConnector {
    private let manager: CBCentralManager

    private var flipperServiceIDs: [CBUUID] {
        [.flipperZerof6, .flipperZeroBlack, .flipperZeroWhite]
    }

    override init() {
        self.manager = CBCentralManager()
        super.init()
        self.manager.delegate = self
    }

    // MARK: BluetoothCentral

    private let statusSubject = SafeValueSubject(BluetoothStatus.notReady(.preparing))
    private let peripheralsSubject = SafeValueSubject([BluetoothPeripheral]())

    var status: SafePublisher<BluetoothStatus> {
        self.statusSubject.eraseToAnyPublisher()
    }

    var peripherals: SafePublisher<[BluetoothPeripheral]> {
        self.peripheralsSubject.eraseToAnyPublisher()
    }

    private var peripheralsMap: OrderedDictionary<UUID, FlipperPeripheral> = [:] {
        didSet { publishPeripherals() }
    }

    private func publishPeripherals() {
        peripheralsSubject.value = [FlipperPeripheral](peripheralsMap.values)
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

    private let connectedPeripheralsSubject = SafeValueSubject([BluetoothPeripheral]())

    var connectedPeripherals: SafePublisher<[BluetoothPeripheral]> {
        self.connectedPeripheralsSubject.eraseToAnyPublisher()
    }

    private var connectedPeripheralsMap = [UUID: FlipperPeripheral]() {
        didSet { publishConnectedPeripherals() }
    }

    private func publishConnectedPeripherals() {
        connectedPeripheralsSubject.value = [FlipperPeripheral](connectedPeripheralsMap.values)
    }

    func connect(to identifier: UUID) {
        manager.retrievePeripherals(withIdentifiers: [identifier]).forEach {
            manager.connect($0)
            connectedPeripheralsMap[$0.identifier] = .init($0)
        }
    }

    func disconnect(from identifier: UUID) {
        manager.retrievePeripherals(withIdentifiers: [identifier]).forEach {
            manager.cancelPeripheralConnection($0)
            // publish disconnecting state for BluetoothConnector subscribers
            connectedPeripheralsMap[$0.identifier] = .init($0)
        }
    }
}

// MARK: BluetoothCentral

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
        self.peripheralsMap[peripheral.identifier] = .init(peripheral)
    }
}

// MARK: BluetoothConnector

extension BluetoothService {
    // MARK: Connection status changed

    func centralManager(
        _ central: CBCentralManager,
        didConnect peripheral: CBPeripheral
    ) {
        if let device = FlipperPeripheral(peripheral) {
            connectedPeripheralsMap[peripheral.identifier] = device
            device.onConnect()
        }
    }

    func centralManager(
        _ central: CBCentralManager,
        didDisconnectPeripheral peripheral: CBPeripheral,
        error: Error?
    ) {
        if let device = connectedPeripheralsMap[peripheral.identifier] {
            // publish disconnected state for BluetoothConnector subscribers
            connectedPeripheralsMap[peripheral.identifier] = .init(peripheral)
            device.onDisconnect()
        }
        connectedPeripheralsMap[peripheral.identifier] = nil
    }

    func centralManager(
        _ central: CBCentralManager,
        didFailToConnect peripheral: CBPeripheral,
        error: Error?
    ) {
        if let device = peripheralsMap[peripheral.identifier] {
            device.onFailToConnect()
        }
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
