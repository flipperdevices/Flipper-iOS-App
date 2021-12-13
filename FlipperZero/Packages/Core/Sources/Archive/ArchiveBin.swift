import Inject
import Combine

protocol ArchiveBinStorage: ArchiveStorage {}

public class ArchiveBin: ObservableObject, ArchiveBinStorage {
    public static let shared: ArchiveBin = .init()
    public lazy var archive: Archive = .shared

    @Inject private var storage: ArchiveBinStorage

    @Published public var items: [ArchiveItem] = [] {
        didSet {
            storage.items = items
        }
    }

    init() {
        self.items = storage.items
    }

    public func add(_ item: ArchiveItem) {
        add([item])
    }

    public func add(_ items: [ArchiveItem]) {
        let items = items.map { item -> ArchiveItem in
            var deleted = item
            deleted.status = .deleted
            return deleted
        }
        self.items.append(contentsOf: items)
    }

    public func delete(_ deleted: ArchiveItem) {
        delete([deleted])
    }

    public func delete(_ deleted: [ArchiveItem]) {
        self.items.removeAll { item in deleted.contains { $0.id == item.id } }
    }

    public func restore(_ deleted: ArchiveItem) {
        restore([deleted])
    }

    public func restore(_ deleted: [ArchiveItem]) {
        deleted.forEach { archive.replace($0) }
        items.removeAll { item in deleted.contains { item.id == $0.id } }
    }
}
