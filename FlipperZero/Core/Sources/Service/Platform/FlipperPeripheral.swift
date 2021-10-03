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

    var received: SafePublisher<Response> {
        delegate.apiSubject.eraseToAnyPublisher()
    }

    func send(_ request: Request) {
        delegate.send(request)
    }
}

// MARK: CBPeripheralDelegate

private class _FlipperPeripheral: NSObject, CBPeripheralDelegate {
    let peripheral: CBPeripheral

    init(_ peripheral: CBPeripheral) {
        self.peripheral = peripheral
        super.init()
        peripheral.delegate = self
    }

    fileprivate let infoSubject = SafeSubject<Void>()
    fileprivate let apiSubject = SafeSubject<Response>()

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

    func handleData(_ data: Data?) {
        guard let data = data else {
            print("no data")
            return
        }
        guard let response = try? Response([UInt8](data)) else {
            print("can't deserialize \(data.count) bytes")
            print(data.debugHexString)
            return
        }
        if case .error(let error) = response {
            print(error)
            return
        }
        apiSubject.send(response)
    }

    func send(_ request: Request) {
        guard peripheral.state == .connected else {
            print("invalid state")
            return
        }
        guard let tx = peripheral.serialWrite else {
            print("no serial service")
            return
        }
        guard let bytes = try? request.serialize(), !bytes.isEmpty else {
            print("can't serialize")
            return
        }
        let data = Data(bytes)
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
