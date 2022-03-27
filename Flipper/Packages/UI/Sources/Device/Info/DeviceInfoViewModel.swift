import Core
import Inject
import Combine
import Peripheral
import Foundation

@MainActor
class DeviceInfoViewModel: ObservableObject {
    let appState: AppState = .shared
    var disposeBag = DisposeBag()

    @Published var flipper: Flipper?
    @Published var deviceInfo: [String: String] = [:]

    init() {
        appState.$flipper
            .receive(on: DispatchQueue.main)
            .assign(to: \.flipper, on: self)
            .store(in: &disposeBag)
    }

    func getDeviceInfo() {
        Task {
            deviceInfo = try await RPC.shared.deviceInfo()
        }
    }
}
