import Peripheral

class MobileArchiveStorage: PlainArchiveStorage {
    init() {
        super.init(root: "mobile")
    }
}
