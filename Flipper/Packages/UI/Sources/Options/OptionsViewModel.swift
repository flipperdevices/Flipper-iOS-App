import Core
import Inject
import Combine
import Peripheral
import Foundation

@MainActor
class OptionsViewModel: ObservableObject {
    @Inject var rpc: RPC
    private let appState: AppState = .shared
    private var disposeBag: DisposeBag = .init()

    @Published var isOnline = false

    init() {
        appState.$status
            .receive(on: DispatchQueue.main)
            .map(\.isOnline)
            .assign(to: \.isOnline, on: self)
            .store(in: &disposeBag)
    }

    func rebootFlipper() {
        Task {
            try await rpc.reboot(to: .os)
        }
    }

    func resetApp() {
        appState.reset()
    }

    func unpairFlipper() {
        Task {
            try await rpc.deleteFile(at: .init(string: "/int/bt.keys"))
            try await rpc.reboot(to: .os)
        }
    }

    func backupKeys() {
        appState.archive.backupKeys()
    }
}
