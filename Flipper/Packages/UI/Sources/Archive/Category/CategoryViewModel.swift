import Core
import Inject
import Combine
import Dispatch

@MainActor
class CategoryViewModel: ObservableObject {
    let name: String
    @Published var items: [ArchiveItem] = []
    var selectedItem: ArchiveItem = .none
    @Published var showInfoView = false

    @Inject private var appState: AppState
    @Inject private var archive: Archive
    var disposeBag = DisposeBag()

    init(name: String, kind: ArchiveItem.Kind) {
        self.name = name

        archive.items
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
