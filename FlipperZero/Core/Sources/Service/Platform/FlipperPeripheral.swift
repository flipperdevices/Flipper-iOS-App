import CoreBluetooth

class FlipperPeripheral: BluetoothPeripheral {
    // swiftlint:disable weak_delegate
    private let delegate: _FlipperPeripheral
    private var peripheral: CBPeripheral { delegate.peripheral }

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

    var screenFrame: SafePublisher<ScreenFrame> {
        delegate.screenFrameSubject.eraseToAnyPublisher()
    }

    func send(
        _ request: Request,
        priority: Priority?
    ) async throws -> Response {
        try await withCheckedThrowingContinuation { continuation in
            delegate.send(request, priority: priority) { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

// MARK: CBPeripheralDelegate

private class _FlipperPeripheral: NSObject, CBPeripheralDelegate {
    let peripheral: CBPeripheral
    let session: Session

    init(_ peripheral: CBPeripheral, _ session: Session) {
        self.peripheral = peripheral
        self.session = session
        super.init()
        peripheral.delegate = self
        session.outputDelegate = self
        session.inputDelegate = self
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
}

extension _FlipperPeripheral: PeripheralOutputDelegate {
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

extension _FlipperPeripheral: PeripheralInputDelegate {
    func onScreenFrame(_ frame: ScreenFrame) {
        screenFrameSubject.send(frame)
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
