import Core
import Combine
import Inject
import Foundation

@MainActor
class DeviceInfoViewModel: ObservableObject {
    let appState: AppState = .shared
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
        appState.$device
            .receive(on: DispatchQueue.main)
            .assign(to: \.device, on: self)
            .store(in: &disposeBag)
    }

    func getDeviceInfo() {
        Task {
            deviceInfo = try await RPC.shared.deviceInfo()
        }
    }

    func disconnectFlipper() {
        appState.forgetDevice()
    }
}
