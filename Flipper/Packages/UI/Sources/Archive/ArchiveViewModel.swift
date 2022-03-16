import Core
import Combine
import Inject
import SwiftUI
import OrderedCollections

@MainActor
class ArchiveViewModel: ObservableObject {
    @Environment(\.presentationMode) var presentationMode

    @Published var appState: AppState = .shared
    @Published var items: [ArchiveItem] = []

    var selectedItem: ArchiveItem?
    @Published var showInfoView = false
    @Published var showSearchView = false
    @Published var hasImportedItem = false

    var importedItem: ArchiveItem? {
        appState.imported.removeFirst()
    }

    var archive: Archive { appState.archive }
    var disposeBag: DisposeBag = .init()

    var categories: [String] = [
        "Sub-GHz", "RFID 125", "NFC", "Infrared", "iButton"
    ]

    var groups: OrderedDictionary<ArchiveItem.FileType, [ArchiveItem]> {
        [
            .subghz: items.filter { $0.fileType == .subghz },
            .rfid: items.filter { $0.fileType == .rfid },
            .nfc: items.filter { $0.fileType == .nfc },
            .infrared: items.filter { $0.fileType == .infrared },
            .ibutton: items.filter { $0.fileType == .ibutton }
        ]
    }

    var deleted: [ArchiveItem] {
        archive.deletedItems
    }

    init() {
        archive.$items
            .receive(on: DispatchQueue.main)
            .assign(to: \.items, on: self)
            .store(in: &disposeBag)

        appState.$imported
            .map { !$0.isEmpty }
            .filter { $0 == true }
            .assign(to: \.hasImportedItem, on: self)
            .store(in: &disposeBag)
    }

    func onItemSelected(item: ArchiveItem) {
        selectedItem = item
        showInfoView = true
    }
}
