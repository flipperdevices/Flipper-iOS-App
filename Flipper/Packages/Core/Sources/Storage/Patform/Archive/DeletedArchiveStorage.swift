import Peripheral

class DeletedArchiveStorage: PlainArchiveStorage {
    init() {
        super.init(root: "deleted")
    }
}
