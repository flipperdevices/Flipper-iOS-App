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

    @Published var isOnline = false

    init() {
        appState.$status
            .receive(on: DispatchQueue.main)
            .map(\.isOnline)
            .assign(to: \.isOnline, on: self)
            .store(in: &disposeBag)
    }
}
