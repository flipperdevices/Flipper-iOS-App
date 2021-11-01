import Core
import Combine
import Injector
import struct Foundation.UUID

class DeviceInfoViewModel: ObservableObject {
    @Inject var connector: BluetoothConnector
    @Inject var pairedDevice: PairedDeviceProtocol
    var disposeBag = DisposeBag()

    @Published var device: Peripheral?

    var name: String {
        device?.name ?? .noDevice
    }

    var uuid: String {
        device?.id.uuidString ?? .noDevice
    }

    init() {
        pairedDevice.peripheral
            .sink { [weak self] device in
                self?.device = device
            }
            .store(in: &disposeBag)
    }

    func disconnectFlipper() {
        pairedDevice.disconnect()
    }
}
