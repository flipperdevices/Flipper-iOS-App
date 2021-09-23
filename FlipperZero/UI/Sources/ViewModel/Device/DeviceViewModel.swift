import Core
import Combine
import Injector
import struct Foundation.UUID

public class DeviceViewModel: ObservableObject {
    @Inject var connector: BluetoothConnector
    @Inject var storage: DeviceStorage
    private var disposeBag: DisposeBag = .init()

    var isReconnecting = false
    @Published var pairedDevice: Peripheral? {
        didSet {
            storage.pairedDevice = pairedDevice
        }
    }

    public init() {
        if let pairedDevice = storage.pairedDevice {
            isReconnecting = true
            self.pairedDevice = pairedDevice
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
                    self.pairedDevice = peripheral
                default:
                    self.pairedDevice = nil
                }
            }
            .store(in: &disposeBag)
    }
}
