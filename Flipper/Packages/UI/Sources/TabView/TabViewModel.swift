import Core
import Inject
import Combine
import Foundation

@MainActor
class TabViewModel: ObservableObject {
    @Inject private var appState: AppState
    private var disposeBag: DisposeBag = .init()

    @Published var status: DeviceStatus = .noDevice
    @Published var syncProgress: Int = 0
    @Published var hasMFLog = false

    init() {
        appState.$status
            .receive(on: DispatchQueue.main)
            .assign(to: \.status, on: self)
            .store(in: &disposeBag)

        appState.$syncProgress
            .receive(on: DispatchQueue.main)
            .assign(to: \.syncProgress, on: self)
            .store(in: &disposeBag)

        appState.$hasMFLog
            .receive(on: DispatchQueue.main)
            .assign(to: \.hasMFLog, on: self)
            .store(in: &disposeBag)
    }
}
