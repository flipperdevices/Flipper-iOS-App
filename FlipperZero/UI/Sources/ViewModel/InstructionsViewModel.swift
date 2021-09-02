import Core
import Combine
import Injector

class InstructionsViewModel: ObservableObject {
    @Inject private var connector: BluetoothConnector

    init() {}

    func checkPermissions() {
        connector.startScanForPeripherals()
        connector.stopScanForPeripherals()
    }
}
