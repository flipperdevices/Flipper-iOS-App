import CoreBluetooth

class FlipperPeripheral: BluetoothPeripheral {
    // swiftlint:disable weak_delegate
    private let delegate: _FlipperPeripheral
    private var peripheral: CBPeripheral { delegate.peripheral }

    var id: UUID
    var name: String
    // TODO: Incapsulate CB objects
    var state: CBPeripheralState { peripheral.state }
    var services: [CBService] { peripheral.services ?? [] }

    init?(_ peripheral: CBPeripheral) {
        guard let name = peripheral.name, name.starts(with: "Flipper ") else {
            return nil
        }
        self.id = peripheral.identifier
        self.name = String(name.dropFirst("Flipper ".count))
        self.delegate = .init(peripheral, FlipperSession())
    }

    func onConnect() {
        delegate.peripheral.discoverServices(nil)
    }

    func onDisconnect() {
        // nothing here yet
    }

    func onFailToConnect() {
        // nothing here yet
    }

    var info: SafePublisher<Void> {
        delegate.infoSubject.eraseToAnyPublisher()
    }

    func send(
        _ request: Request,
        priority: Priority?,
        continuation: @escaping Continuation
    ) {
        delegate.send(request, priority: priority, continuation: continuation)
    }
}

// MARK: CBPeripheralDelegate

private class _FlipperPeripheral: NSObject, CBPeripheralDelegate, SessionDelegate {
    let peripheral: CBPeripheral
    let session: Session

    init(_ peripheral: CBPeripheral, _ session: Session) {
        self.peripheral = peripheral
        self.session = session
        super.init()
        peripheral.delegate = self
        session.delegate = self
    }

    fileprivate let infoSubject = SafeSubject<Void>()

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
            print(service.uuid, characteristic.properties.contains(.notify))
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

    func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateValueFor characteristic: CBCharacteristic,
        error: Swift.Error?
    ) {
        assert(peripheral === self.peripheral)
        switch characteristic.uuid {
        case .serialRead:
            if let data = characteristic.value {
                session.didReceiveData(data)
            }
        case .flowControl:
            if let data = characteristic.value {
                session.didReceiveFlowControl(data)
            }
        default:
            infoSubject.send()
        }
    }

    func send(
        _ request: Request,
        priority: Priority?,
        continuation: @escaping Continuation
    ) {
        session.sendRequest(
            request,
            priority: priority,
            continuation: continuation)
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
