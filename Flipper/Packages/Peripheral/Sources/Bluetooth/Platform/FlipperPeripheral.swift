import Combine
import CoreBluetooth

class FlipperPeripheral: NSObject, BluetoothPeripheral {
    private var peripheral: CBPeripheral
    private var serialWrite: CBCharacteristic?

    var id: UUID
    var name: String
    var color: FlipperColor
    var state: FlipperState {
        didSet { infoSubject.send(()) }
    }

    var freeSpace = 0

    var maximumWriteValueLength: Int {
        min(freeSpace,
            peripheral.maximumWriteValueLength(for: .withoutResponse))
    }

    var services: [FlipperService] {
        peripheral.services?.map { FlipperService($0) } ?? []
    }
    // FIXME: Temporary workaround to ignore cache
    private var updatedDeviceInfoCharacteristics: Set<CBUUID> = .init()

    var info: AnyPublisher<Void, Never> {
        infoSubject.eraseToAnyPublisher()
    }

    var canWrite: AnyPublisher<Void, Never> {
        canWriteSubject.eraseToAnyPublisher()
    }

    var received: AnyPublisher<Data, Never> {
        receivedDataSubject.eraseToAnyPublisher()
    }

    fileprivate let infoSubject = PassthroughSubject<Void, Never>()
    fileprivate let canWriteSubject = PassthroughSubject<Void, Never>()
    fileprivate let receivedDataSubject = PassthroughSubject<Data, Never>()

    init(
        peripheral: CBPeripheral,
        service: CBUUID? = nil
    ) {
        self.id = peripheral.identifier
        self.name = String(name: peripheral.name)
        self.color = .init(service)
        self.peripheral = peripheral
        self.state = .init(peripheral.state)
        super.init()
        self.peripheral.delegate = self
    }

    func onConnecting() {
        state = .connecting
    }

    func onConnect() {
        peripheral.discoverServices(nil)
    }

    func onDisconnect() {
        guard state != .pairingFailed, state != .invalidPairing else {
            return
        }
        state = .disconnected
    }

    func onError(_ error: Swift.Error) {
        switch error {
        case let error as CBATTError: _onError(error)
        case let error as CBError: _onError(error)
        default: logger.error("unknown error type: \(error)")
        }
    }

    private func _onError(_ error: CBError) {
        switch error.code {
        case .peerRemovedPairingInformation: state = .invalidPairing
        case .encryptionTimedOut: state = .disconnected
        default: logger.error("unknown error type: \(error)")
        }
    }

    private func _onError(_ error: CBATTError) {
        switch error.code {
        case .insufficientEncryption: state = .pairingFailed
        default: logger.error("unknown error type: \(error)")
        }
    }

    func send(_ data: Data) {
        guard state == .connected else {
            logger.error("invalid state")
            return
        }
        guard let serialWrite = serialWrite else {
            logger.critical("no serial service")
            return
        }
        peripheral.writeValue(data, for: serialWrite, type: .withResponse)
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
        guard let characteristics = service.characteristics else {
            logger.critical("service \(service.uuid) has no characteristics")
            return
        }
        switch service.uuid {
        case .deviceInformation: didDiscoverDeviceInformation(characteristics)
        case .battery: didDiscoverBattery(characteristics)
        case .serial: didDiscoverSerial(characteristics)
        default: logger.debug("unknown service discovered")
        }
    }

    func didDiscoverDeviceInformation(_ characteristics: [CBCharacteristic]) {
        characteristics.forEach { characteristic in
            peripheral.readValue(for: characteristic)
        }
    }

    func didDiscoverBattery(_ characteristics: [CBCharacteristic]) {
        guard let batteryLevel = characteristics.batteryLevel else {
            logger.critical("invalid battery service")
            return
        }
        peripheral.setNotifyValue(true, for: batteryLevel)
        peripheral.readValue(for: batteryLevel)

        if let batteryPowerState = characteristics.batteryPowerState {
            peripheral.setNotifyValue(true, for: batteryPowerState)
            peripheral.readValue(for: batteryPowerState)
            return
        }
    }

    func didDiscoverSerial(_ characteristics: [CBCharacteristic]) {
        guard let serialRead = characteristics.serialRead else {
            logger.critical("invalid serial read service")
            return
        }
        guard let serialWrite = characteristics.serialWrite else {
            logger.critical("invalid serial write service")
            return
        }
        guard let flowControl = characteristics.flowControl else {
            logger.critical("invalid flow control service")
            return
        }
        peripheral.setNotifyValue(true, for: serialRead)
        peripheral.setNotifyValue(true, for: flowControl)
        peripheral.readValue(for: flowControl)
        self.serialWrite = serialWrite
    }

    // MARK: Values

    func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateValueFor characteristic: CBCharacteristic,
        error: Swift.Error?
    ) {
        guard error == nil else {
            onError(error.unsafelyUnwrapped)
            return
        }
        switch characteristic.uuid {
        case .serialRead: didUpdateSerialRead(characteristic)
        case .flowControl: didUpdateFlowControl(characteristic)
        default: didUpdateDeviceInformation(characteristic)
        }
    }

    func didUpdateSerialRead(_ characteristic: CBCharacteristic) {
        guard let data = characteristic.value else {
            logger.critical("invalid serial read data")
            return
        }
        receivedDataSubject.send(data)
    }

    func didUpdateFlowControl(_ characteristic: CBCharacteristic) {
        guard let freeSpace = characteristic.value?.int32Value else {
            logger.critical("invalid flow control data")
            return
        }
        self.freeSpace = freeSpace
        guard freeSpace > 0 else {
            logger.info("flow control value is 0")
            return
        }
        canWriteSubject.send(())
    }

    func didUpdateDeviceInformation(_ characteristic: CBCharacteristic) {
        guard
            let services = peripheral.services,
            let info = services.first(where: { $0.uuid == .deviceInformation }),
            let characteristics = info.characteristics
        else {
            return
        }
        guard characteristics.allSatisfy({ isUpdated($0) }) else {
            markAsUpdated(characteristic)
            return
        }
        state = .connected
    }

    // FIXME: Temporary workaround to ignore cache

    func isUpdated(_ characteristic: CBCharacteristic) -> Bool {
        updatedDeviceInfoCharacteristics.contains(characteristic.uuid)
    }

    func markAsUpdated(_ characteristic: CBCharacteristic) {
        updatedDeviceInfoCharacteristics.insert(characteristic.uuid)
    }
}

fileprivate extension String {
    init(name: String?) {
        guard let name = name else {
            self = "Unknown"
            return
        }
        self = name.starts(with: "Flipper ")
            ? String(name.dropFirst("Flipper ".count))
            : name
    }
}

extension FlipperColor {
    init(_ service: CBUUID?) {
        switch service {
        case .some(.flipperZeroBlack): self = .black
        case .some(.flipperZeroWhite): self = .white
        default: self = .unknown
        }
    }
}

extension FlipperState {
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

extension FlipperService {
    init(_ source: CBService) {
        self.name = source.uuid.description
        self.characteristics = source.characteristics?
            .map(Characteristic.init) ?? []
    }
}

extension FlipperService.Characteristic {
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
