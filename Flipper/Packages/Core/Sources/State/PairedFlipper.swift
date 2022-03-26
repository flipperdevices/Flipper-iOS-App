import Inject
import Bluetooth
import Combine

import struct Foundation.UUID

class PairedFlipper: PairedDevice, ObservableObject {
    @Inject var connector: BluetoothConnector
    @Inject var storage: DeviceStorage
    var disposeBag: DisposeBag = .init()

    var flipper: SafePublisher<Flipper?> {
        flipperSubject.eraseToAnyPublisher()
    }
    private var flipperSubject: SafeValueSubject<Flipper?>

    private var infoBag: AnyCancellable?
    private var bluetoothPeripheral: BluetoothPeripheral? {
        didSet { flipperDidChange() }
    }
    var isPairingFailed: Bool {
        bluetoothPeripheral?.isPairingFailed ?? false
    }

    init() {
        flipperSubject = .init(nil)
        flipperSubject.value = storage.flipper

        connector.status
            .filter { $0 == .ready }
            .sink { [weak self] _ in
                self?.onBluetoothReady()
            }
            .store(in: &disposeBag)

        connector.connected
            .sink { [weak self] peripherals in
                self?.onConnectedPeripherals(peripherals)
            }
            .store(in: &disposeBag)
    }

    func onBluetoothReady() {
        if let flipper = flipperSubject.value {
            connector.connect(to: flipper.id)
        }
    }

    func onConnectedPeripherals(_ peripherals: [BluetoothPeripheral]) {
        guard let peripheral = peripherals.first else {
            // don't forget device but update state
            if bluetoothPeripheral?.state == .disconnected {
                flipperDidChange()
            }
            return
        }
        bluetoothPeripheral = peripheral
    }

    func flipperDidChange() {
        if let peripheral = bluetoothPeripheral {
            flipperSubject.value = merge(peripheral)
            storage.flipper = flipperSubject.value
            subscribeToUpdates()
        } else {
            flipperSubject.value = nil
            storage.flipper = nil
            infoBag = nil
        }
    }

    func subscribeToUpdates() {
        infoBag = bluetoothPeripheral?.info
            .sink { [weak self] in
                self?.flipperDidChange()
            }
    }

    func merge(_ bluetoothPeripheral: BluetoothPeripheral) -> Flipper {
        var flipper = Flipper(bluetoothPeripheral)
        guard let current = flipperSubject.value else {
            return flipper
        }
        // we don't have color on connect
        // so we have to copy initial value
        flipper.color = current.color
        return flipper
    }

    func connect() {
        if let peripheral = bluetoothPeripheral {
            connector.connect(to: peripheral.id)
        }
    }

    func disconnect() {
        if let peripheral = bluetoothPeripheral {
            connector.disconnect(from: peripheral.id)
        }
    }

    func forget() {
        disconnect()
        bluetoothPeripheral = nil
    }
}
