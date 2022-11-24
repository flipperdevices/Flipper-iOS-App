import Core
import Combine
import Inject
import SwiftUI
import OrderedCollections

@MainActor
class SettingsSelectKeyViewModel: ObservableObject {
    @Inject private var appState: AppState
    @Inject private var archive: Archive
    private var disposeBag: DisposeBag = .init()

    var widgetKeys: [WidgetKey]
    var onItemSelected: (ArchiveItem) -> Void

    @Published var predicate = ""

    @Published var items: [ArchiveItem] = []
    var filteredItems: [ArchiveItem] {
        items.filter { item in
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

        archive
            .items
            .receive(on: DispatchQueue.main)
            .assign(to: \.items, on: self)
            .store(in: &disposeBag)
    }
}

private extension ArchiveItem {
    var isAllowed: Bool {
        kind == .subghz || kind == .nfc || kind == .rfid || kind == .ibutton
    }
}
