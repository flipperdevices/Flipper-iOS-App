import Peripheral

class NotesArchiveStorage: PlainArchiveStorage {
    init() {
        super.init(root: "notes")
    }
}
