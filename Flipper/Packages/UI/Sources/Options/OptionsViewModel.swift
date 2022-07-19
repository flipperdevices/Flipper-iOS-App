import Core
import Inject
import Combine
import Peripheral
import Foundation
import Logging

@MainActor
class OptionsViewModel: ObservableObject {
    private let logger = Logger(label: "options-vm")

    @Inject var rpc: RPC
    private let appState: AppState = .shared
    private var disposeBag: DisposeBag = .init()

    @Published var isOnline = false
    @Published var hasKeys = false

    var appVersion: String {
        Bundle.releaseVersion
    }

    init() {
        appState.$status
            .receive(on: DispatchQueue.main)
            .map(\.isOnline)
            .assign(to: \.isOnline, on: self)
            .store(in: &disposeBag)

        appState.archive.$items
            .receive(on: DispatchQueue.main)
            .map { !$0.isEmpty }
            .assign(to: \.hasKeys, on: self)
            .store(in: &disposeBag)
    }

    func rebootFlipper() {
        Task {
            do {
                try await rpc.reboot(to: .os)
            } catch {
                logger.error("reboot flipper: \(error)")
            }
        }
    }

    func resetApp() {
        appState.reset()
    }

    func backupKeys() {
        appState.archive.backupKeys()
    }
}
