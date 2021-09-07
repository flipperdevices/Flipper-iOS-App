import Core
import Combine
import Injector
import struct Foundation.UUID

public class DeviceViewModel: ObservableObject {
    @Inject var connector: BluetoothConnector
    @Inject var storage: LocalStorage
    private var disposeBag: DisposeBag = .init()

    @Published var pairedDeviceUUID: UUID?
    var isReconnecting = false

    public init() {
        if let lastConnectedDevice = storage.lastConnectedDevice {
            isReconnecting = true
            pairedDeviceUUID = lastConnectedDevice
            reconnectOnBluetoothReady(to: lastConnectedDevice)
        }
        saveLastConnectedDeviceOnConnect()
    }

    func reconnectOnBluetoothReady(to uuid: UUID) {
        connector
            .status
            .sink { status in
                if status == .ready {
                    self.connector.connect(to: uuid)
                }
            }
            .store(in: &disposeBag)
    }

    func saveLastConnectedDeviceOnConnect() {
        connector
            .connectedPeripheral
            .sink { peripheral in
                if peripheral == nil, self.isReconnecting {
                    self.isReconnecting = false
                    return
                }
                self.pairedDeviceUUID = peripheral?.id
                self.storage.lastConnectedDevice = peripheral?.id
            }
            .store(in: &disposeBag)
    }
}
