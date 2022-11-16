import Core
import Combine
import Inject
import SwiftUI
import OrderedCollections

@MainActor
class ArchiveSearchViewModel: ObservableObject {
    @Inject private var appState: AppState
    @Inject private var archive: Archive

    var items: [ArchiveItem] = []
    var disposeBag: DisposeBag = .init()
    var selectedItem: ArchiveItem = .none

    @Published var predicate = ""
    @Published var showInfoView = false

    var filteredItems: [ArchiveItem] {
        guard !predicate.isEmpty else {
            return items
        }
        return items.filter {
            $0.name.value.lowercased().contains(predicate.lowercased()) ||
            $0.note.lowercased().contains(predicate.lowercased())
        }
    }

    init() {
        archive
            .items
            .receive(on: DispatchQueue.main)
            .assign(to: \.items, on: self)
            .store(in: &disposeBag)
    }

    func onItemSelected(item: ArchiveItem) {
        selectedItem = item
        showInfoView = true
    }
}
