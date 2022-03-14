import Core
import Combine
import SwiftUI

class ImportViewModel: ObservableObject {
    let backup: ArchiveItem
    @Published var item: ArchiveItem
    @Published var isEditMode = false

    let appState: AppState = .shared

    init(item: ArchiveItem?) {
        self.item = item ?? .none
        self.backup = item ?? .none
    }

    func add() -> Bool {
        true
    }

    func edit() {
        isEditMode = true
    }

    func saveChanges() {
        isEditMode = false
    }

    func undoChanges() {
        isEditMode = false
    }
}

extension ArchiveItem {
    static var none: Self {
        .init(
            name: "",
            fileType: .ibutton,
            properties: [])
    }
}
