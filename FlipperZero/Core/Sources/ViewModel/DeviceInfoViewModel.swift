import Combine

class DeviceInfoViewModel: ObservableObject {
    @Inject private var connector: BluetoothConnector

    @Published var device: Peripheral?
    private var disposeBag: DisposeBag = .init()

    init() {
        connector.connectedPeripheral
            .sink {
                self.device = $0
            }
            .store(in: &disposeBag)
    }

    func forgetConnectedDevice() {
        if let device = device {
            connector.forget(about: device.id)
        }
    }
}
