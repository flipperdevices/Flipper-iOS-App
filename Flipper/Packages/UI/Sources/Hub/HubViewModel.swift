import Core
import Inject
import Combine
import Peripheral
import Foundation
import Logging

@MainActor
class HubViewModel: ObservableObject {
    private let logger = Logger(label: "hub-vm")

    @Inject private var rpc: RPC
    @Inject private var appState: AppState
    private var disposeBag: DisposeBag = .init()

    @Published var hasMFLog = false

    init() {
        appState.$hasMFLog
            .receive(on: DispatchQueue.main)
            .assign(to: \.hasMFLog, on: self)
            .store(in: &disposeBag)
    }
}
