import Core
import Combine
import Foundation

class TabViewModel: ObservableObject {
    private let appState: AppState = .shared
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
