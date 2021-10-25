import Combine
import Injector
import struct Foundation.UUID

class PairedDevice: PairedDeviceProtocol, ObservableObject {
    @Inject var connector: BluetoothConnector
    @Inject var storage: DeviceStorage
    var disposeBag: DisposeBag = .init()

    private var isReconnecting = false
    private var peripheralSubject: SafeValueSubject<Peripheral?> = .init(nil)

    private var flipper: BluetoothPeripheral? {
        didSet { subscribeToUpdates() }
    }

    var peripheral: SafePublisher<Peripheral?> {
        peripheralSubject.eraseToAnyPublisher()
    }

    init() {
        if let pairedDevice = storage.pairedDevice {
            isReconnecting = true
            peripheralSubject.value = pairedDevice
            reconnectOnBluetoothReady(to: pairedDevice.id)
        }

        saveLastConnectedDeviceOnConnect()
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
                    if self.isReconnecting { self.isReconnecting = false }
                    return
                }
                switch peripheral.state {
                // TODO: handle .connecting
                case .connecting, .connected:
                    self.flipper = peripheral
                    self.peripheralSubject.value = .init(peripheral)
                default:
                    self.flipper = nil
                    self.peripheralSubject.value = nil
                }
            }
            .store(in: &disposeBag)
    }

    func subscribeToUpdates() {
        flipper?.info
            .sink { [weak self] in
                if let flipper = self?.flipper {
                    self?.peripheralSubject.value = .init(flipper)
                }
            }
            .store(in: &disposeBag)
    }

    func disconnect() {
        if let flipper = flipper {
            connector.disconnect(from: flipper.id)
        }
    }

    func send(_ request: Request, continuation: @escaping (Response) -> Void) {
        flipper?.send(request, continuation: continuation)
    }
}
