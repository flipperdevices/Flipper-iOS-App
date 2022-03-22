import Combine
import Inject
import struct Foundation.UUID

class PairedFlipper: PairedDevice, ObservableObject {
    @Inject var connector: BluetoothConnector
    @Inject var storage: DeviceStorage
    var disposeBag: DisposeBag = .init()

    var peripheral: SafePublisher<Peripheral?> {
        peripheralSubject.eraseToAnyPublisher()
    }
    private var peripheralSubject: SafeValueSubject<Peripheral?>

    private var infoBag: AnyCancellable?
    private var flipper: BluetoothPeripheral? {
        didSet { flipperDidChange() }
    }
    var isPairingFailed: Bool {
        flipper?.isPairingFailed ?? false
    }

    init() {
        peripheralSubject = .init(nil)
        peripheralSubject.value = storage.pairedDevice

        connector.status
            .filter { $0 == .ready }
            .sink { [weak self] _ in
                self?.onBluetoothReady()
            }
            .store(in: &disposeBag)

        connector.connectedPeripherals
            .sink { [weak self] peripherals in
                self?.onConnectedPeripherals(peripherals)
            }
            .store(in: &disposeBag)
    }

    func onBluetoothReady() {
        if let peripheral = peripheralSubject.value {
            connector.connect(to: peripheral.id)
        }
    }

    func onConnectedPeripherals(_ peripherals: [BluetoothPeripheral]) {
        guard let peripheral = peripherals.first else {
            // don't forget device but update state
            if self.flipper?.state == .disconnected {
                self.flipperDidChange()
            }
            return
        }
        flipper = peripheral
    }

    func flipperDidChange() {
        if let flipper = flipper {
            peripheralSubject.value = merge(peripheralSubject.value, flipper)
            storage.pairedDevice = peripheralSubject.value
            subscribeToUpdates()
        } else {
            peripheralSubject.value = nil
            storage.pairedDevice = nil
            infoBag = nil
        }
    }

    func subscribeToUpdates() {
        infoBag = flipper?.info
            .sink { [weak self] in
                self?.flipperDidChange()
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

        return peripheral
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
        flipper = nil
    }
}
