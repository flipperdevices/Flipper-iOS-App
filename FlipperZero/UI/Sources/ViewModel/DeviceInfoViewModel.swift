import Core
import Combine
import Injector

class DeviceInfoViewModel: ObservableObject {
    @Inject private var connector: BluetoothConnector

    @Published var device: Peripheral?
    private var disposeBag: DisposeBag = .init()

    init() {
        connector.connectedPeripherals
            .sink { [weak self] in
                self?.device = $0.first {
                    // TODO: handle .connecting
                    $0.state == .connecting || $0.state == .connected
                }
            }
            .store(in: &disposeBag)
    }

    func forgetConnectedDevice() {
        if let device = device {
            connector.disconnect(from: device.id)
        }
    }
}
