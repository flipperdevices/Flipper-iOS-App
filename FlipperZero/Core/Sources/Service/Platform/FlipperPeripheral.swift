import CoreBluetooth

class FlipperPeripheral: BluetoothPeripheral {
    // swiftlint:disable weak_delegate
    private let flipperDelegate: _FlipperPeripheral
    private var peripheral: CBPeripheral { flipperDelegate.peripheral }

    var delegate: PeripheralDelegate? {
        get { flipperDelegate.delegate }
        set { flipperDelegate.delegate = newValue }
    }

    var id: UUID
    var name: String

    var state: Peripheral.State { .init(peripheral.state) }
    // TODO: Incapsulate CB objects
    var services: [CBService] { peripheral.services ?? [] }

    init?(_ peripheral: CBPeripheral) {
        guard let name = peripheral.name, name.starts(with: "Flipper ") else {
            return nil
        }
        self.id = peripheral.identifier
        self.name = String(name.dropFirst("Flipper ".count))
        self.flipperDelegate = .init(peripheral)
    }

    func onConnect() {
        flipperDelegate.peripheral.discoverServices(nil)
    }

    func onDisconnect() {
        // nothing here yet
    }

    func onFailToConnect() {
        // nothing here yet
    }

    var info: SafePublisher<Void> {
        flipperDelegate.infoSubject.eraseToAnyPublisher()
    }

    func send(_ data: Data) {
        flipperDelegate.send(data)
    }
}

// MARK: CBPeripheralDelegate

private class _FlipperPeripheral: NSObject, CBPeripheralDelegate {
    let peripheral: CBPeripheral
    weak var delegate: PeripheralDelegate?

    init(_ peripheral: CBPeripheral) {
        self.peripheral = peripheral
        super.init()
        peripheral.delegate = self
    }

    fileprivate let infoSubject = SafeSubject<Void>()
    fileprivate let screenFrameSubject = SafeSubject<ScreenFrame>()

    // MARK: Services

    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverServices error: Swift.Error?
    ) {
        peripheral.services?.forEach { service in
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    // MARK: Characteristics

    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverCharacteristicsFor service: CBService,
        error: Swift.Error?
    ) {
        service.characteristics?.forEach { characteristic in
            // subscribe to rx updates
            if characteristic.properties.contains(.indicate) {
                peripheral.setNotifyValue(true, for: characteristic)
            }
            // subscibe to value updates
            if characteristic.properties.contains(.notify) {
                peripheral.setNotifyValue(true, for: characteristic)
            }
            if service.uuid != .serial || characteristic.uuid == .flowControl {
                // read current value
                peripheral.readValue(for: characteristic)
            }
        }
    }

    // MARK: Values

    var mtu: Int {
        peripheral.maximumWriteValueLength(for: .withoutResponse)
    }

    func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateValueFor characteristic: CBCharacteristic,
        error: Swift.Error?
    ) {
        assert(peripheral === self.peripheral)
        switch characteristic.uuid {
        case .serialRead:
            if let data = characteristic.value {
                delegate?.didReceiveData(data)
            }
        case .flowControl:
            if let data = characteristic.value {
                delegate?.didReceiveFlowControl(freeSpace: data, packetSize: mtu)
            }
        default:
            infoSubject.send()
        }
    }

    func send(_ data: Data) {
        guard peripheral.state == .connected else {
            print("invalid state")
            return
        }
        guard let tx = peripheral.serialWrite else {
            print("no serial service")
            return
        }
        peripheral.writeValue(data, for: tx, type: .withResponse)
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
