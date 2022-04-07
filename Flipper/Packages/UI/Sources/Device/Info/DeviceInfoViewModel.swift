import Core
import Inject
import Combine
import Peripheral
import Foundation

@MainActor
class DeviceInfoViewModel: ObservableObject {
    @Inject var rpc: RPC
    let appState: AppState = .shared
    var disposeBag = DisposeBag()

    @Published var flipper: Flipper?
    @Published var deviceInfo: [String: String] = [:]

    var manufacturerName: String {
        guard let info = flipper?.information else { return "—" }
        return info.manufacturerName
    }

    var serialNumber: String {
        guard let info = flipper?.information else { return "—" }
        return info.serialNumber
    }

    var firmwareRevision: String {
        guard let info = flipper?.information else { return "—" }
        return info.firmwareRevision
    }

    var softwareRevision: String {
        guard let info = flipper?.information else { return "—" }
        return info.softwareRevision
    }

    var protobufRevision: String {
        guard let info = flipper?.information else { return "—" }
        return info.protobufRevision.rawValue
    }

    init() {
        appState.$flipper
            .receive(on: DispatchQueue.main)
            .assign(to: \.flipper, on: self)
            .store(in: &disposeBag)
    }

    func getDeviceInfo() {
        Task {
            deviceInfo = try await rpc.deviceInfo()
        }
    }
}
