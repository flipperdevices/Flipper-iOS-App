import Core
import Combine
import Inject
import struct Foundation.UUID

@MainActor
class DeviceInfoViewModel: ObservableObject {
    @Inject var pairedDevice: PairedDevice
    var disposeBag = DisposeBag()

    @Published var device: Peripheral?
    @Published var deviceInfo: [String: String] = [:]

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

    func getDeviceInfo() {
        Task {
            deviceInfo = try await RPC.shared.deviceInfo()
        }
    }

    func disconnectFlipper() {
        pairedDevice.disconnect()
    }
}
