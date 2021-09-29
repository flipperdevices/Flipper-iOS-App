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
        guard var data = data else {
            print("no data")
            return
        }
        data.removeFirst()
        guard let main = try? PB_Main(serializedData: data) else {
            print("can't deserialize", [UInt8](data))
            return
        }
        switch main.content {
        case .pingResponse: apiSubject.send(.ping)
        default: print("unsupported api response:", main.content ?? "nil")
        }
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
        let request = makeProtobufMessage(for: request)
        guard var data = try? request.serializedData() else {
            print("can't serialize")
            return
        }
        data.insert(UInt8(data.count), at: 0)
        peripheral.writeValue(data, for: tx, type: .withResponse)
    }

    func makeProtobufMessage(for request: Request) -> PB_Main {
        switch request {
        case .ping:
            return PB_Main.with { $0.pingRequest = PBStatus_PingRequest() }
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
