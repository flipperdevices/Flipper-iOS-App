import Core
import Combine

@MainActor
class OptionsViewModel: ObservableObject {
    let appState: AppState = .shared

    var hideTabbar: (Bool) -> Void = { _ in }

    init(hideTabbar: @escaping (Bool) -> Void = { _ in }) {
        self.hideTabbar = hideTabbar
    }

    func resetApp() {
        appState.reset()
    }
}
