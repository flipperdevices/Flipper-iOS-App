import Core
import Combine
import Foundation

@MainActor
class OptionsViewModel: ObservableObject {
    private let rpc: RPC = .shared
    private let appState: AppState = .shared
    private var disposeBag: DisposeBag = .init()

    @Published var isConnected = false
    @Published var hasOTASupport = false

    init() {
        appState.$device
            .receive(on: DispatchQueue.main)
            .map { $0?.state == .connected }
            .assign(to: \.isConnected, on: self)
            .store(in: &disposeBag)

        appState.$capabilities
            .receive(on: DispatchQueue.main)
            .compactMap(\.?.hasOTASupport)
            .assign(to: \.hasOTASupport, on: self)
            .store(in: &disposeBag)
    }

    func playAlert() {
        Task {
            try await rpc.playAlert()
        }
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
}
