import Core
import Combine
import Inject
import SwiftUI
import OrderedCollections

@MainActor
class SettingsSelectKeyViewModel: ObservableObject {
    let appState: AppState = .shared

    var widgetKeys: [WidgetKey]
    var onItemSelected: (ArchiveItem) -> Void

    @Published var predicate = ""

    var filteredItems: [ArchiveItem] {
        appState.archive.items.filter { item in
            guard item.isAllowed else {
                return false
            }
            guard !widgetKeys.contains(where: { $0.path == item.path }) else {
                return false
            }
            guard !predicate.isEmpty else {
                return true
            }
            return item.name.value.lowercased().contains(predicate.lowercased())
                || item.note.lowercased().contains(predicate.lowercased())
        }
    }

    init(
        widgetKeys: [WidgetKey],
        onItemSelected: @escaping (ArchiveItem) -> Void
    ) {
        self.widgetKeys = widgetKeys
        self.onItemSelected = onItemSelected
    }
}

private extension ArchiveItem {
    var isAllowed: Bool {
        kind == .subghz || kind == .nfc || kind == .rfid
    }
}
