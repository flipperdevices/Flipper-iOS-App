import Core
import Combine
import Foundation

@MainActor
class OptionsViewModel: ObservableObject {
    let appState: AppState = .shared
    private var disposeBag: DisposeBag = .init()

    @Published var canPlayAlert = false

    init() {
        appState.$capabilities
            .receive(on: DispatchQueue.main)
            .compactMap(\.?.canPlayAlert)
            .assign(to: \.canPlayAlert, on: self)
            .store(in: &disposeBag)
    }

    func resetApp() {
        appState.reset()
    }
}
