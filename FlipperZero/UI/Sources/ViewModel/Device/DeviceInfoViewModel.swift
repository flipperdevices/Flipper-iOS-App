import Core
import Combine
import Injector
import struct Foundation.UUID

class DeviceInfoViewModel: ObservableObject {
    @Inject var connector: BluetoothConnector
    @Published var device: Peripheral
    var disposeBag = DisposeBag()

    init() {
        self.device = .init(id: UUID(), name: "unknown")

        connector.connectedPeripherals
            .filter { !$0.isEmpty }
            .sink { [weak self] devices in
                self?.device = devices[0]
            }
            .store(in: &disposeBag)
    }

    func forgetConnectedDevice() {
        connector.disconnect(from: device.id)
    }
}
