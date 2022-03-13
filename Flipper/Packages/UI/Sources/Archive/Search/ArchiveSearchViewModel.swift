import Core
import Combine
import Inject
import SwiftUI
import OrderedCollections

@MainActor
class ArchiveSearchViewModel: ObservableObject {
    let appState: AppState = .shared

    var filteredItems: [ArchiveItem] {
        appState.archive.items.filter {
            $0.name.value.lowercased().contains(predicate.lowercased())
        }
    }

    @Published var predicate = ""

    var selectedItem: ArchiveItem?
    @Published var showInfoView = false

    init() {}

    func onItemSelected(item: ArchiveItem) {
        selectedItem = item
        showInfoView = true
    }
}
