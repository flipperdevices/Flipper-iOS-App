import Peripheral

class DeletedArchive: FileSystemArchive {
    init(storage: FileSystemArchiveAPI) {
        super.init(storage: storage, root: "deleted")
    }
}
