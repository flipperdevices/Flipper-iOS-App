import Core
import Combine
import Injector
import struct Foundation.UUID

public class DeviceViewModel: ObservableObject {
    @Inject var connector: BluetoothConnector
    @Inject var storage: LocalStorage
    private var disposeBag: DisposeBag = .init()

    var isReconnecting = false
    @Published var pairedDeviceUUID: UUID? {
        didSet { storage.lastConnectedDevice = pairedDeviceUUID }
    }

    public init() {
        if let lastConnectedDevice = storage.lastConnectedDevice {
            isReconnecting = true
            pairedDeviceUUID = lastConnectedDevice
            reconnectOnBluetoothReady(to: lastConnectedDevice)
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
                    self.pairedDeviceUUID = peripherals.first?.id
                default:
                    self.pairedDeviceUUID = nil
                }
            }
            .store(in: &disposeBag)
    }
}
