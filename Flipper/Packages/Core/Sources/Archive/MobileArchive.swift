import Inject
import Bluetooth

class MobileArchive: MobileArchiveProtocol {
    @Inject var storage: ArchiveStorage

    var items: [ArchiveItem.ID: ArchiveItem] = [:] {
        didSet {
            storage.items = .init(items.values)
        }
    }

    var manifest: Manifest {
        var items: [Path: Hash] = [:]
        for item in self.items.values {
            items[item.path] = item.hash
        }
        return .init(items)
    }

    init() {
        for item in storage.items {
            self.items[item.id] = item
        }
    }

    func read(_ id: ArchiveItem.ID) async throws -> ArchiveItem {
        guard let item = items[id] else {
            fatalError("unreachable: invalid id")
        }
        return item
    }

    func upsert(_ item: ArchiveItem) async throws {
        items[item.id] = item
    }

    func delete(_ id: ArchiveItem.ID) async throws {
        items.removeValue(forKey: id)
    }
}
