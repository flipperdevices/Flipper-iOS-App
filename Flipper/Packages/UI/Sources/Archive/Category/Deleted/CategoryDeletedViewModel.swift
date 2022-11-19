import Core
import Inject
import Combine
import Dispatch
import Logging

@MainActor
class CategoryDeletedViewModel: ObservableObject {
    private let logger = Logger(label: "category-deleted-vm")

    @Inject private var archive: Archive

    @Published var items: [ArchiveItem] = []
    var selectedItem: ArchiveItem = .none
    @Published var showInfoView = false
    @Published var showRestoreSheet = false
    @Published var showDeleteSheet = false

    @Inject private var appState: AppState
    var disposeBag = DisposeBag()

    init() {
        archive.deletedItems
            .receive(on: DispatchQueue.main)
            .assign(to: \.items, on: self)
            .store(in: &disposeBag)
    }

    func onItemSelected(item: ArchiveItem) {
        selectedItem = item
        showInfoView = true
    }

    func restoreAll() {
        Task {
            do {
                try await archive.restoreAll()
                try await appState.synchronize()
            } catch {
                logger.error("restore all: \(error)")
            }
        }
    }

    func deleteAll() {
        Task {
            do {
                try await archive.wipeAll()
            } catch {
                logger.error("delete all: \(error)")
            }
        }
    }
}
