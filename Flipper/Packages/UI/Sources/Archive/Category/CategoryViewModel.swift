import Core
import Combine
import Dispatch

@MainActor
class CategoryViewModel: ObservableObject {
    let name: String
    @Published var items: [ArchiveItem] = []
    var selectedItem: ArchiveItem?
    @Published var showInfoView = false

    let appState: AppState = .shared
    var disposeBag = DisposeBag()

    init(name: String, fileType: ArchiveItem.FileType) {
        self.name = name

        appState.archive.$items
            .map { $0.filter { $0.fileType == fileType } }
            .receive(on: DispatchQueue.main)
            .assign(to: \.items, on: self)
            .store(in: &disposeBag)
    }

    func onItemSelected(item: ArchiveItem) {
        selectedItem = item
        showInfoView = true
    }
}
