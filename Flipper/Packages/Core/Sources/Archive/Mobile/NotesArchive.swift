import Peripheral

class NotesArchive: FileSystemArchive {
    init(storage: FileSystemArchiveAPI) {
        super.init(storage: storage, root: "notes")
    }
}
