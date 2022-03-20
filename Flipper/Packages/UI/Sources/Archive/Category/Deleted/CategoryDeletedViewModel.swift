import Core
import Combine
import Dispatch

@MainActor
class CategoryDeletedViewModel: ObservableObject {
    @Published var items: [ArchiveItem] = []
    var selectedItem: ArchiveItem?
    @Published var showInfoView = false
    @Published var showDeleteSheet = false

    let appState: AppState = .shared
    var disposeBag = DisposeBag()

    init() {
        appState.archive.$deletedItems
            .receive(on: DispatchQueue.main)
            .assign(to: \.items, on: self)
            .store(in: &disposeBag)
    }

    func onItemSelected(item: ArchiveItem) {
        selectedItem = item
        showInfoView = true
    }

    func deleteAll() {
        Task {
            try await appState.archive.wipeAll()
        }
    }
}
