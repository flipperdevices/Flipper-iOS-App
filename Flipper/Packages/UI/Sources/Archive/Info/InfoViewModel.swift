import Core
import Combine

class InfoViewModel: ObservableObject {
    @Published var item: ArchiveItem
    @Published var isEditMode = false

    init(item: ArchiveItem?) {
        self.item = item ?? .none
    }

    func edit() {
        isEditMode = true
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
