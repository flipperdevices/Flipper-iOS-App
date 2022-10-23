import Core
import Inject
import Combine
import Peripheral
import Foundation
import Logging

@MainActor
class NFCToolsViewModel: ObservableObject {
    private let logger = Logger(label: "hub-vm")

    @Inject var rpc: RPC
    private let appState: AppState = .shared
    private var disposeBag: DisposeBag = .init()

    @Published var hasMFLog = false

    init() {
        appState.$hasMFLog
            .receive(on: DispatchQueue.main)
            .assign(to: \.hasMFLog, on: self)
            .store(in: &disposeBag)
    }
}
