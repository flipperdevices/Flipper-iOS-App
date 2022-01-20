import CoreBluetooth
import Logging

class FlipperPeripheral: NSObject, BluetoothPeripheral {
    private let logger = Logger(label: "peripheral")

    private var peripheral: CBPeripheral

    var id: UUID
    var name: String
    var color: Peripheral.Color

    var isPairingFailed = false

    var freeSpace = 0

    var maximumWriteValueLength: Int {
        min(freeSpace,
            peripheral.maximumWriteValueLength(for: .withoutResponse))
    }

    var state: Peripheral.State {
        .init(peripheral.state)
    }

    var services: [Peripheral.Service] {
        peripheral.services?.map { Peripheral.Service($0) } ?? []
    }

    var info: SafePublisher<Void> {
        infoSubject.eraseToAnyPublisher()
    }

    var canWrite: SafePublisher<Void> {
        canWriteSubject.eraseToAnyPublisher()
    }

    var received: SafePublisher<Data> {
        receivedDataSubject.eraseToAnyPublisher()
    }

    fileprivate let infoSubject = SafeSubject<Void>()
    fileprivate let canWriteSubject = SafeSubject<Void>()
    fileprivate let receivedDataSubject = SafeSubject<Data>()

    init?(
        peripheral: CBPeripheral,
        colorService service: CBUUID? = nil
    ) {
        guard let name = peripheral.name, name.starts(with: "Flipper ") else {
            return nil
        }
        self.id = peripheral.identifier
        self.name = String(name.dropFirst("Flipper ".count))
        self.color = .init(service)
        self.peripheral = peripheral
        super.init()
        self.peripheral.delegate = self
    }

    func onConnect() {
        isPairingFailed = false
        peripheral.discoverServices(nil)
    }

    func onDisconnect() {
        // nothing here yet
    }

    func onError(_ error: CBATTError?) {
        guard let error = error else {
            return
        }
        if error.code == .insufficientEncryption {
            isPairingFailed = true
        }
    }

    func onFailToConnect() {
        // nothing here yet
    }

    func send(_ data: Data) {
        guard peripheral.state == .connected else {
            logger.error("invalid state")
            return
        }
        guard let tx = peripheral.serialWrite else {
            logger.critical("no serial service")
            return
        }
        peripheral.writeValue(data, for: tx, type: .withResponse)
        freeSpace -= data.count
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

    func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateValueFor characteristic: CBCharacteristic,
        error: Swift.Error?
    ) {
        assert(peripheral === self.peripheral)
        guard error == nil else {
            onError(error as? CBATTError)
            return
        }
        switch characteristic.uuid {
        case .serialRead:
            if let data = characteristic.value {
                receivedDataSubject.send(data)
            }
        case .flowControl:
            if let data = characteristic.value {
                freeSpace = data.int32Value
                if freeSpace > 0 {
                    canWriteSubject.send(())
                }
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

extension Peripheral.Color {
    init(_ service: CBUUID?) {
        switch service {
        case .some(.flipperZeroBlack): self = .black
        case .some(.flipperZeroWhite): self = .white
        default: self = .unknown
        }
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

extension Data {
    var int32Value: Int {
        Int(withUnsafeBytes {
            $0.load(as: Int32.self).bigEndian
        })
    }
}
