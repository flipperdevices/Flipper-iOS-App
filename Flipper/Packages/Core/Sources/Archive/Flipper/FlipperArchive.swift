import Peripheral

class FlipperArchive: FileSystemArchive {
    init(storage: StorageAPI) {
        super.init(storage: FlipperArchiveAPI(storage: storage), root: "/")
    }
}
