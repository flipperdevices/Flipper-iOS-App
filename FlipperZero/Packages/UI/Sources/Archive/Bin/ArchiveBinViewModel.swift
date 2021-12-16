import Core
import Combine
import Inject
import SwiftUI

@MainActor
class ArchiveBinViewModel: ObservableObject {
    @Published var archive: Archive = .shared
    @Published var sheetManager: SheetManager = .shared

    var items: [ArchiveItem] {
        archive.items.filter { $0.status == .deleted }
    }

    @Published var isActionPresented = false
    @Published var selectedItem: ArchiveItem = .none

    init() {}

    func deleteSelectedItems() {
        guard selectedItem != .none else {
            return
        }
        archive.wipe(selectedItem)
    }

    func restoreSelectedItems() {
        guard selectedItem != .none else {
            return
        }
        archive.restore(selectedItem)
    }
}
