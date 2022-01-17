import Combine
import Inject
import struct Foundation.UUID

class PairedFlipper: PairedDevice, ObservableObject {
    @Inject var connector: BluetoothConnector
    @Inject var storage: DeviceStorage
    var disposeBag: DisposeBag = .init()

    private var peripheralSubject: SafeValueSubject<Peripheral?> = .init(nil)

    private var flipper: BluetoothPeripheral? {
        didSet {
            if oldValue == nil, flipper != nil {
                subscribeToUpdates()
            }
            flipperDidChange()
        }
    }

    var peripheral: SafePublisher<Peripheral?> {
        peripheralSubject.eraseToAnyPublisher()
    }

    init() {
        if let pairedDevice = storage.pairedDevice {
            peripheralSubject.value = pairedDevice
            reconnectOnBluetoothReady(to: pairedDevice.id)
        }

        saveLastConnectedDeviceOnConnect()
    }

    func flipperDidChange() {
        if let flipper = flipper {
            let peripheral = merge(peripheralSubject.value, flipper)
            storage.pairedDevice = peripheral
            peripheralSubject.value = peripheral
        } else {
            storage.pairedDevice = nil
            peripheralSubject.value = nil
        }
    }

    func merge(
        _ peripheral: Peripheral?,
        _ bluetoothPeripheral: BluetoothPeripheral
    ) -> Peripheral {
        var peripheral = Peripheral(bluetoothPeripheral)
        guard let current = peripheralSubject.value else {
            return peripheral
        }

        // we don't have color on connect
        // so we have to copy initial value
        peripheral.color = current.color

        // we don't have device info on connect
        // and we want to keep the existing one
        if peripheral.information == nil, let info = current.information {
            peripheral.information = info
        }

        return peripheral
    }

    func reconnectOnBluetoothReady(to uuid: UUID) {
        connector.status
            .sink { [weak self] status in
                if status == .ready {
                    self?.connector.connect(to: uuid)
                }
            }
            .store(in: &disposeBag)
    }

    func saveLastConnectedDeviceOnConnect() {
        connector
            .connectedPeripherals
            .sink { [weak self] peripherals in
                guard let self = self else { return }
                guard let peripheral = peripherals.first else {
                    // NOTE: Pairing issue
                    if self.flipper?.state == .disconnected {
                        self.flipperDidChange()
                    }
                    return
                }
                self.flipper = peripheral
            }
            .store(in: &disposeBag)
    }

    func subscribeToUpdates() {
        flipper?.info
            .sink { [weak self] in
                if let flipper = self?.flipper {
                    self?.flipper = flipper
                }
            }
            .store(in: &disposeBag)
    }

    func connect() {
        if let flipper = self.flipper {
            connector.connect(to: flipper.id)
        }
    }

    func disconnect() {
        if let flipper = self.flipper {
            connector.disconnect(from: flipper.id)
        }
    }

    func forget() {
        disconnect()
        self.flipper = nil
    }
}
