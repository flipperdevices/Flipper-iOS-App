import Core
import Combine
import Dispatch

@MainActor
class CategoryViewModel: ObservableObject {
    let name: String
    @Published var items: [ArchiveItem] = []
    var selectedItem: ArchiveItem = .none
    @Published var showInfoView = false

    let appState: AppState = .shared
    var archive: Archive { appState.archive }
    var disposeBag = DisposeBag()

    init(name: String, kind: ArchiveItem.Kind) {
        self.name = name

        appState.archive.$items
            .map { $0.filter { $0.kind == kind } }
            .receive(on: DispatchQueue.main)
            .assign(to: \.items, on: self)
            .store(in: &disposeBag)
    }

    func onItemSelected(item: ArchiveItem) {
        selectedItem = item
        showInfoView = true
    }
}
