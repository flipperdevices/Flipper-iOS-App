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
        self.delegate = .init(peripheral)
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

    func send(_ request: Request, continuation: @escaping (Response) -> Void) {
        delegate.send(request, continuation: continuation)
    }
}

// MARK: CBPeripheralDelegate

private class _FlipperPeripheral: NSObject, CBPeripheralDelegate {
    let peripheral: CBPeripheral

    let chunkedResponse: ChunkedResponse = .init()
    let sequencedResponse: SequencedResponse = .init()

    let sequencedRequest: SequencedRequest = .init()
    let chunkedRequest: ChunkedRequest = .init()

    init(_ peripheral: CBPeripheral) {
        self.peripheral = peripheral
        super.init()
        peripheral.delegate = self
    }

    fileprivate let infoSubject = SafeSubject<Void>()

    // MARK: Services

    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverServices error: Error?
    ) {
        peripheral.services?.forEach { service in
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    // MARK: Characteristics

    func peripheral(
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

    func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateValueFor characteristic: CBCharacteristic,
        error: Error?
    ) {
        assert(peripheral === self.peripheral)
        switch characteristic.uuid {
        case .serialRead:
            handleData(characteristic.value)
        default:
            infoSubject.send()
        }
    }

    // TODO: Move to FlipperSession

    var request: Request?
    var continuation: ((Response) -> Void)?

    func handleData(_ data: Data?) {
        do {
            guard let data = data else { return }
            // single PB_Main can be split into ble chunks;
            // returns nil if data.count < main.size
            guard let nextResponse = try chunkedResponse.feed(data) else {
                return
            }
            // complete PB_Main can be split into multiple messages
            guard let response = try sequencedResponse.feed(nextResponse) else {
                return
            }
            // TODO: Compare message id
            if case .error(let error) = response {
                print(error)
            }
            guard let continuation = self.continuation else {
                print("unexpected response", response)
                return
            }
            self.request = nil
            self.continuation = nil
            continuation(response)
        } catch {
            print(error)
        }
    }

    func send(_ request: Request, continuation: @escaping (Response) -> Void) {
        self.request = request
        self.continuation = continuation

        func error(_ message: String) {
            print(message)
            continuation(.error(message))
        }

        guard peripheral.state == .connected else {
            error("invalid state")
            return
        }
        guard let tx = peripheral.serialWrite else {
            error("no serial service")
            return
        }

        let requests = sequencedRequest.split(request)
        for request in requests {
            let chunks = chunkedRequest.split(request)
            for chunk in chunks {
                guard !chunk.isEmpty else {
                    error("empty chunk")
                    return
                }
                let data = Data(chunk)
                peripheral.writeValue(data, for: tx, type: .withResponse)
            }
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
