import Core
import Combine
import Inject
import SwiftUI
import OrderedCollections

@MainActor
class ArchiveSearchViewModel: ObservableObject {
    let appState: AppState = .shared

    @Published var predicate = ""

    var filteredItems: [ArchiveItem] {
        appState.archive.items.filter {
            $0.name.value.lowercased().contains(predicate.lowercased())
        }
    }

    init() {}
}
