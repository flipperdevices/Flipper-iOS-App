import CoreBluetooth

class FlipperPeripheral: NSObject, BluetoothPeripheral {
    private var peripheral: CBPeripheral
    weak var delegate: PeripheralDelegate?

    var id: UUID
    var name: String

    var state: Peripheral.State {
        .init(peripheral.state)
    }

    var services: [Peripheral.Service] {
        peripheral.services?.map { Peripheral.Service($0) } ?? []
    }

    var info: SafePublisher<Void> {
        infoSubject.eraseToAnyPublisher()
    }

    fileprivate let infoSubject = SafeSubject<Void>()

    init?(_ peripheral: CBPeripheral) {
        guard let name = peripheral.name, name.starts(with: "Flipper ") else {
            return nil
        }
        self.id = peripheral.identifier
        self.name = String(name.dropFirst("Flipper ".count))
        self.peripheral = peripheral
    }

    func onConnect() {
        peripheral.discoverServices(nil)
    }

    func onDisconnect() {
        // nothing here yet
    }

    func onFailToConnect() {
        // nothing here yet
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

// MARK: CBPeripheralDelegate

// NOTE: if you want to make FlipperPeripheral public,
//       search for _FlipperPeripheral wrapper in history

extension FlipperPeripheral: CBPeripheralDelegate {

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
}

fileprivate extension CBPeripheral {
    var serialWrite: CBCharacteristic? {
        services?
            .first { $0.uuid == .serial }?
            .characteristics?
            .first { $0.uuid == .serialWrite }
    }
}

extension Peripheral.State {
    init(_ source: CBPeripheralState) {
        // swiftlint:disable switch_case_on_newline
        switch source {
        case .disconnected: self = .disconnected
        case .connecting: self = .connecting
        case .connected: self = .connected
        case .disconnecting: self = .disconnecting
        @unknown default: self = .disconnected
        }
    }
}

extension Peripheral.Service {
    init(_ source: CBService) {
        self.name = source.uuid.description
        self.characteristics = source.characteristics?
            .map(Characteristic.init) ?? []
    }
}

extension Peripheral.Service.Characteristic {
    init(_ source: CBCharacteristic) {
        self.name = source.uuid.description
        switch source.value {
        case let .some(data): self.value = .init(data)
        case .none: self.value = []
        }
    }
}
