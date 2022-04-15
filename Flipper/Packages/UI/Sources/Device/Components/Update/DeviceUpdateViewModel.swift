import Core
import Inject
import Combine
import Peripheral
import Foundation

@MainActor
class DeviceUpdateViewModel: ObservableObject {
    private let appState: AppState = .shared
    private var disposeBag: DisposeBag = .init()

    @Published var flipper: Flipper?

    var isConnected: Bool {
        flipper?.state == .connected
    }

    var protobufVersion: ProtobufVersion? {
        flipper?.information?.protobufRevision
    }

    var firmwareVersion: String? {
        flipper?.information?
            .softwareRevision
            .split(separator: " ")
            .dropFirst()
            .prefix(1)
            .joined()
    }

    init() {
        appState.$flipper
            .receive(on: DispatchQueue.main)
            .assign(to: \.flipper, on: self)
            .store(in: &disposeBag)
    }

    func update() {
        print("update")
    }
}
