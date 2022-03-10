import Core
import Combine
import Inject
import SwiftUI

@MainActor
class ArchiveViewModel: ObservableObject {
    @Published var appState: AppState = .shared
    @Published var items: [ArchiveItem] = []

    var archive: Archive { appState.archive }
    var disposeBag: DisposeBag = .init()

    var categories: [String] = [
        "Sub-GHz", "RFID 125", "NFC", "Infrared", "iButton"
    ]

    struct Group: Identifiable, Equatable {
        var id: ArchiveItem.FileType?
        var items: [ArchiveItem]
    }

    var itemGroups: [Group] {
        [
            .init(id: nil, items: items),
            .init(id: .rfid, items: items.filter { $0.fileType == .rfid }),
            .init(id: .subghz, items: items.filter { $0.fileType == .subghz }),
            .init(id: .nfc, items: items.filter { $0.fileType == .nfc }),
            .init(id: .ibutton, items: items.filter { $0.fileType == .ibutton }),
            .init(id: .infrared, items: items.filter { $0.fileType == .infrared })
        ]
    }

    init() {
        archive.$items
            .receive(on: DispatchQueue.main)
            .assign(to: \.items, on: self)
            .store(in: &disposeBag)
    }
}
