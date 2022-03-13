import Core
import Combine
import Inject
import SwiftUI
import OrderedCollections

@MainActor
class ArchiveViewModel: ObservableObject {
    @Published var appState: AppState = .shared
    @Published var items: [ArchiveItem] = []

    @Published var showSearchView = false

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
    }
}
