class JSONArchiveBinStorage: ArchiveBinStorage {
    let storage: JSONStorage<[ArchiveItem]>

    var items: [ArchiveItem] {
        get { read() }
        set { write(newValue) }
    }

    init() {
        storage = .init(for: [ArchiveItem].self, filename: "bin")
    }

    func read() -> [ArchiveItem] {
        storage.read() ?? []
    }

    func write(_ archive: [ArchiveItem]) {
        if !archive.isEmpty {
            storage.write(archive)
        } else {
            storage.delete()
        }
    }
}
