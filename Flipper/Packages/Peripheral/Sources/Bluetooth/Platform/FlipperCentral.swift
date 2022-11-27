import Inject
import CoreBluetooth
import Logging

class FlipperCentral: NSObject, BluetoothCentral, BluetoothConnector {
    private let logger = Logger(label: "central")

    private lazy var manager: CBCentralManager = {
        let manager = CBCentralManager()
        manager.delegate = self
        return manager
    }()

    @Inject var factory: PeripheralFactory

    private var serviceKey: String {
        "kCBAdvDataServiceUUIDs"
    }
    private var flipperServiceIDs: [CBUUID] {
        [.flipperZerof6, .flipperZeroBlack, .flipperZeroWhite]
    }

    override init() {
        super.init()
    }

    // MARK: BluetoothCentral & BluetoothConnector

    var status: SafePublisher<BluetoothStatus> {
        _status.eraseToAnyPublisher()
    }
    let _status: SafeValueSubject<BluetoothStatus> = {
        .init(.notReady(.preparing))
    }()

    // MARK: BluetoothCentral

    var discovered: SafePublisher<[BluetoothPeripheral]> {
        _discovered.eraseToAnyPublisher()
    }
    let _discovered: SafeValueSubject<[BluetoothPeripheral]> = {
        .init([])
    }()

    func startScanForPeripherals() {
        if _status.value == .ready {
            manager.scanForPeripherals(withServices: flipperServiceIDs)
        }
    }

    func stopScanForPeripherals() {
        if manager.isScanning {
            manager.stopScan()
            _discovered.value.removeAll()
        }
    }

    // MARK: BluetoothConnector

    var connected: SafePublisher<[BluetoothPeripheral]> {
        _connected.eraseToAnyPublisher()
    }
    let _connected: SafeValueSubject<[BluetoothPeripheral]> = {
        .init([])
    }()

    func connect(to id: UUID) {
        guard let peripheral = manager.retrievePeripheral(id) else {
            return
        }
        let device = factory.create(peripheral: peripheral)
        device.onConnecting()
        _connected[id] = device
        manager.connect(peripheral)
    }

    func disconnect(from identifier: UUID) {
        if let peripheral = manager.retrievePeripheral(identifier) {
            manager.cancelPeripheralConnection(peripheral)
        }
    }

    func didConnect(_ peripheral: CBPeripheral) {
        if let peripheral = _connected[peripheral.identifier] {
            peripheral.onConnect()
            _connected[peripheral.id] = peripheral
        }
    }

    func didDisconnect(_ peripheral: CBPeripheral, error: Swift.Error?) {
        if let peripheral = _connected[peripheral.identifier] {
            peripheral.onDisconnect()
            _connected[peripheral.id] = nil
        }
    }

    func didFailToConnect(_ peripheral: CBPeripheral, error: Swift.Error?) {
        if let device = _connected[peripheral.identifier], let error = error {
            device.onError(error)
            _connected[device.id] = nil
        }
    }
}

// MARK: BluetoothCentral

extension FlipperCentral: CBCentralManagerDelegate {

    // MARK: Status changed

    func centralManagerDidUpdateState(_ manager: CBCentralManager) {
        if manager.state != .poweredOn {
            _discovered.value.removeAll()
            _connected.value.removeAll()
        }
        _status.value = .init(manager.state)
    }

    // MARK: Did discover

    func centralManager(
        _: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi: NSNumber
    ) {
        let service = (advertisementData[serviceKey] as? [CBUUID])?.first
        if _discovered[peripheral.identifier] == nil {
            _discovered[peripheral.identifier] = factory.create(
                peripheral: peripheral,
                service: service)
        }
    }
}

// MARK: BluetoothConnector

extension FlipperCentral {

    // MARK: Connection status changed

    func centralManager(
        _ central: CBCentralManager,
        didConnect peripheral: CBPeripheral
    ) {
        didConnect(peripheral)
    }

    func centralManager(
        _ central: CBCentralManager,
        didDisconnectPeripheral peripheral: CBPeripheral,
        error: Swift.Error?
    ) {
        didDisconnect(peripheral, error: error)
    }

    func centralManager(
        _ central: CBCentralManager,
        didFailToConnect peripheral: CBPeripheral,
        error: Swift.Error?
    ) {
        didFailToConnect(peripheral, error: error)
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

extension Array where Element == BluetoothPeripheral {
    subscript(_ id: UUID) -> Element? {
        get {
            first { $0.id == id }
        }
        set {
            if let index = firstIndex(where: { $0.id == id }) {
                if let newValue = newValue {
                    self[index] = newValue
                } else {
                    remove(at: index)
                }
            } else {
                if let newValue = newValue {
                    append(newValue)
                }
            }
        }
    }
}

extension SafeValueSubject where Output == [BluetoothPeripheral] {
    subscript(_ id: UUID) -> Output.Element? {
        get { self.value[id] }
        set { self.value[id] = newValue }
    }
}
