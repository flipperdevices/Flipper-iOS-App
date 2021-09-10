import Core
import Combine
import Injector

class DeviceInfoViewModel: ObservableObject {
    @Inject var connector: BluetoothConnector
    @Published var device: Peripheral

    init(_ device: Peripheral) {
        self.device = device
    }

    func forgetConnectedDevice() {
        connector.disconnect(from: device.id)
    }
}
