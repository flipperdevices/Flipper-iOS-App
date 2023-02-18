import Peripheral

import Logging
import Combine

import struct Foundation.UUID

class PairedFlipper: PairedDevice, ObservableObject {
    private var storage: DeviceStorage
    private var central: BluetoothCentral
    private var cancellables: [AnyCancellable] = .init()

    var session: Session = ClosedSession.shared

    var flipper: AnyPublisher<Flipper?, Never> {
        _flipper.eraseToAnyPublisher()
    }
    private var _flipper: CurrentValueSubject<Flipper?, Never> = {
        .init(nil)
    }()

    private var infoBag: AnyCancellable?
    private var bluetoothPeripheral: BluetoothPeripheral? {
        didSet {
            guard let peripheral = bluetoothPeripheral else {
                session = ClosedSession.shared
                return
            }
            if oldValue == nil {
                restartSession(with: peripheral)
            }

            peripheralDidChange()
        }
    }

    init(central: BluetoothCentral, storage: DeviceStorage) {
        self.central = central
        self.storage = storage
        _flipper.value = storage.flipper
        subscribeToPublishers()
    }

    func subscribeToPublishers() {
        central.connected
            .map { $0.first }
            .assign(to: \.bluetoothPeripheral, on: self)
            .store(in: &cancellables)
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

    func restartSession(with peripheral: BluetoothPeripheral) {
        let backup = session
        session = FlipperSession(peripheral: peripheral)
        session.onScreenFrame = backup.onScreenFrame
        session.onAppStateChanged = backup.onAppStateChanged
    }

    func subscribeToUpdates() {
        infoBag = bluetoothPeripheral?.info
            .sink { [weak self] in
                self?.peripheralDidUpdate()
            }
    }

    func connect() {
        if let flipper = _flipper.value {
            central.connect(to: flipper.id)
        }
    }

    func disconnect() {
        if let peripheral = bluetoothPeripheral {
            central.disconnect(from: peripheral.id)
        }
    }

    func forget() {
        disconnect()
        _flipper.value = nil
        storage.flipper = nil
        bluetoothPeripheral = nil
    }
}

extension PairedFlipper {
    public func updateStorageInfo(_ storageInfo: Flipper.StorageInfo) {
        _flipper.value?.storage = storageInfo
        storage.flipper = _flipper.value
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
        if let storage = _flipper.value?.storage {
            flipper.storage = storage
        }
        return flipper
    }
}
