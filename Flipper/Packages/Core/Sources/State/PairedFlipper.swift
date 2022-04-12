import Inject
import Peripheral
import Combine
import Logging

import struct Foundation.UUID

class PairedFlipper: PairedDevice, ObservableObject {
    private let logger = Logger(label: "paired_flipper")

    @Inject var storage: DeviceStorage
    @Inject var connector: BluetoothConnector
    private var disposeBag: DisposeBag = .init()

    private var bluetoothStatus: BluetoothStatus = .notReady(.preparing) {
        didSet { didUpdateBluetoothStatus() }
    }

    var flipper: SafePublisher<Flipper?> { _flipper.eraseToAnyPublisher() }
    private var _flipper: SafeValueSubject<Flipper?> = .init(nil)

    private var infoBag: AnyCancellable?
    private var bluetoothPeripheral: BluetoothPeripheral? {
        didSet { peripheralDidChange() }
    }

    init() {
        _flipper.value = storage.flipper

        connector.status
            .assign(to: \.bluetoothStatus, on: self)
            .store(in: &disposeBag)

        connector.connected
            .map { $0.first }
            .assign(to: \.bluetoothPeripheral, on: self)
            .store(in: &disposeBag)
    }

    func didUpdateBluetoothStatus() {
        if bluetoothStatus == .ready {
            connect()
        }
    }

    func peripheralDidChange() {
        peripheralDidUpdate()
        subscribeToUpdates()
    }

    func peripheralDidUpdate() {
        if let peripheral = bluetoothPeripheral {
            _flipper.value = _init(peripheral)
            storage.flipper = _init(peripheral)
        }
    }

    func subscribeToUpdates() {
        infoBag = bluetoothPeripheral?.info
            .sink { [weak self] in
                self?.peripheralDidUpdate()
            }
    }

    func connect() {
        if let flipper = _flipper.value {
            connector.connect(to: flipper.id)
        }
    }

    func disconnect() {
        if let peripheral = bluetoothPeripheral {
            connector.disconnect(from: peripheral.id)
        }
    }

    func forget() {
        disconnect()
        _flipper.value = nil
        storage.flipper = nil
        bluetoothPeripheral = nil
    }
}

fileprivate extension PairedFlipper {
    // TODO: Move to factory, store all discovered services
    func _init(_ bluetoothPeripheral: BluetoothPeripheral) -> Flipper {
        // we don't have color on connect
        // so we have to copy initial value
        var flipper = Flipper(bluetoothPeripheral)
        if let color = _flipper.value?.color {
            flipper.color = color
        }
        return flipper
    }
}
