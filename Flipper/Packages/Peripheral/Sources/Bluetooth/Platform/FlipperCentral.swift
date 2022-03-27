import Combine
import CoreBluetooth
import Collections
import Foundation
import Logging
import UIKit

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

    var colorService: [UUID: CBUUID] = [:]

    // MARK: BluetoothCentral

    var status: SafePublisher<BluetoothStatus> {
        _status.eraseToAnyPublisher()
    }
    let _status: SafeValueSubject<BluetoothStatus> = {
        .init(.notReady(.preparing))
    }()

    var discovered: SafePublisher<[BluetoothPeripheral]> {
        _discovered.eraseToAnyPublisher()
    }
    let _discovered: SafeValueSubject<[BluetoothPeripheral]> =  {
        .init([])
    }()

    func startScanForPeripherals() {
        if _status.value == .ready {
            self.manager.scanForPeripherals(withServices: flipperServiceIDs)
        }
    }

    func stopScanForPeripherals() {
        if manager.isScanning {
            _discovered.value.removeAll()
            manager.stopScan()
        }
    }

    // MARK: BluetoothConnector

    var connected: SafePublisher<[BluetoothPeripheral]> {
        _connected.eraseToAnyPublisher()
    }
    let _connected: SafeValueSubject<[BluetoothPeripheral]> = {
        .init([])
    }()

    func connect(to identifier: UUID) {
        manager.retrievePeripherals(withIdentifiers: [identifier]).forEach {
            guard let peripheral = FlipperPeripheral(
                peripheral: $0,
                colorService: colorService[$0.identifier]
            ) else {
                return
            }
            manager.connect($0)
            _connected[$0.identifier] = peripheral
            manager.registerForConnectionEvents(options: [
                .peripheralUUIDs: [$0.identifier]
            ])

            catchPairingIssue(for: identifier)
        }
    }

    func catchPairingIssue(for identifier: UUID) {
        Task {
            guard let peripheral = _connected[identifier] else {
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
            _connected[$0.identifier] = nil
        }
    }

    func didConnect(_ peripheral: CBPeripheral) {
        assert(_connected[peripheral.identifier] != nil)
        _connected.send(_connected.value)
        _connected[peripheral.identifier]?.onConnect()
    }

    func didDisconnect(_ peripheral: CBPeripheral) {
        if let device = _connected[peripheral.identifier] {
            _connected[peripheral.identifier] = nil
            device.onDisconnect()
        }
    }

    func didFailPairing(_ peripheral: BluetoothPeripheral) {
        _connected[peripheral.id] = nil
    }
}

// MARK: BluetoothCentral

extension FlipperCentral: CBCentralManagerDelegate {

    // MARK: Status changed

    func centralManagerDidUpdateState(_ manager: CBCentralManager) {
        if manager.state != .poweredOn {
            _discovered.value.removeAll()
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
        self.colorService[peripheral.identifier] =
            (advertisementData["kCBAdvDataServiceUUIDs"] as? [CBUUID])?.first

        _discovered[peripheral.identifier] = FlipperPeripheral(
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
