import Core
import Combine
import Injector
import struct Foundation.UUID

class DeviceInfoViewModel: ObservableObject {
    @Inject var connector: BluetoothConnector
    var flipper: BluetoothPeripheral? {
        didSet { subscribeToUpdates() }
    }
    var disposeBag = DisposeBag()

    @Published var device: Peripheral

    init() {
        self.device = .init(id: UUID(), name: "unknown")

        connector.connectedPeripherals
            .filter { !$0.isEmpty }
            .sink { [weak self] devices in
                self?.flipper = devices[0]
            }
            .store(in: &disposeBag)
    }

    func subscribeToUpdates() {
        flipper?.info
            .sink { [weak self] in
                if let flipper = self?.flipper {
                    self?.device = .init(flipper)
                }
            }
            .store(in: &disposeBag)
    }

    func forgetConnectedDevice() {
        connector.disconnect(from: device.id)
    }
}
