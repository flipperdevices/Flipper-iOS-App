import Core
import Combine
import Injector
import struct Foundation.UUID

public class RootViewModel: ObservableObject {
    @Inject var connector: BluetoothConnector
    @Inject var storage: LocalStorage
    private var disposeBag: DisposeBag = .init()

    public init() {
        if let lastConnectedDevice = storage.lastConnectedDevice {
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
                self.storage.lastConnectedDevice = peripheral?.id
            }
            .store(in: &disposeBag)
    }
}
