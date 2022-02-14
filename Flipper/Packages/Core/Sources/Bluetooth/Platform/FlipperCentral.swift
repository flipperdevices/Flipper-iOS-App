import CoreBluetooth
import Collections
import Foundation
import Logging

class FlipperCentral: NSObject, BluetoothCentral, BluetoothConnector {
    private let logger = Logger(label: "central")

    private lazy var manager: CBCentralManager = {
        let manager = CBCentralManager()
        manager.delegate = self
        return manager
    }()

    private var flipperServiceIDs: [CBUUID] {
        [.flipperZerof6, .flipperZeroBlack, .flipperZeroWhite]
    }

    override init() {
        super.init()
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

    private var colorService: [UUID: CBUUID] = [:]

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

            connectedPeripheralsMap[$0.identifier] = .init(
                peripheral: $0,
                colorService: colorService[$0.identifier])

            manager.registerForConnectionEvents(options: [
                .peripheralUUIDs: [$0.identifier]
            ])

            catchPairingIssue(for: identifier)
        }
    }

    func catchPairingIssue(for identifier: UUID) {
        Task {
            guard let peripheral = connectedPeripheralsMap[identifier] else {
                return
            }
            while peripheral.state == .connecting {
                try await Task.sleep(nanoseconds: 10 * 1_000_000)
            }
            if peripheral.state == .disconnected {
                didFailPairing(peripheral)
            }
        }
    }

    func disconnect(from identifier: UUID) {
        manager.retrievePeripherals(withIdentifiers: [identifier]).forEach {
            manager.cancelPeripheralConnection($0)
            connectedPeripheralsMap[$0.identifier] = nil
        }
    }

    func didConnect(_ peripheral: CBPeripheral) {
        assert(connectedPeripheralsMap[peripheral.identifier] != nil)
        publishConnectedPeripherals()
        connectedPeripheralsMap[peripheral.identifier]?.onConnect()
    }

    func didDisconnect(_ peripheral: CBPeripheral) {
        if let device = connectedPeripheralsMap[peripheral.identifier] {
            connectedPeripheralsMap[peripheral.identifier] = nil
            device.onDisconnect()
        }
    }

    func didFailPairing(_ peripheral: FlipperPeripheral) {
        connectedPeripheralsMap[peripheral.id] = nil
    }
}

// MARK: BluetoothCentral

extension FlipperCentral: CBCentralManagerDelegate {

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
        self.colorService[peripheral.identifier] =
            (advertisementData["kCBAdvDataServiceUUIDs"] as? [CBUUID])?.first

        self.peripheralsMap[peripheral.identifier] = .init(
            peripheral: peripheral,
            colorService: colorService[peripheral.identifier])
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

    // FIXME: Not triggered anymore for some reason

    func centralManager(
        _ central: CBCentralManager,
        didDisconnectPeripheral peripheral: CBPeripheral,
        error: Error?
    ) {
        logger.info("did disconnect peripheral")
    }

    func centralManager(
        _ central: CBCentralManager,
        didFailToConnect peripheral: CBPeripheral,
        error: Error?
    ) {
        logger.info("did fail to connect")
    }

    // MARK: Workaround

    func centralManager(
        _ central: CBCentralManager,
        connectionEventDidOccur event: CBConnectionEvent,
        for peripheral: CBPeripheral
    ) {
        switch event {
        case .peerDisconnected:
            didDisconnect(peripheral)
        case .peerConnected:
            // Actual peripheral state is .connecting
            // Use centralManager didConnect as it has more accurate state
            // didConnect(peripheral)
            break
        default:
            logger.critical("unhandled event: \(event)")
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
