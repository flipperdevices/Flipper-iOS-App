import Core
import Combine
import SwiftUI

class InfoViewModel: ObservableObject {
    let backup: ArchiveItem
    @Published var item: ArchiveItem
    @Published var isEditMode = false

    init(item: ArchiveItem?) {
        self.item = item ?? .none
        self.backup = item ?? .none
    }

    func edit() {
        withAnimation {
            isEditMode = true
        }
    }

    func share() {
    }

    func delete() {
    }

    func saveChanges() {
        isEditMode = false
    }

    func undoChanges() {
        isEditMode = false
    }
}
