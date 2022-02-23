import Combine
import Core

class ImportViewModel: ObservableObject {
    let appState: AppState = .shared

    @Published var item: ArchiveItem

    init() {
        self.item = .none
    }

    func save() {
    }

    func cancel() {
    }
}
