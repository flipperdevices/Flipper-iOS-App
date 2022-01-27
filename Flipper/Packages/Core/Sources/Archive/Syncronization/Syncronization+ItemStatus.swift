extension Synchronization {
    enum ItemStatus: Equatable {
        case deleted
        case modified(Hash)
    }
}

// MARK: Manifest changes

extension Manifest {
    func changesSince(
        _ manifest: Manifest
    ) -> [ArchiveItem.ID: Synchronization.ItemStatus] {
        var result: [ArchiveItem.ID: Synchronization.ItemStatus] = [:]

        let paths = Set(self.items.map { $0.id })
            .union(manifest.items.map { $0.id })

        for path in paths {
            let newItem = self[path]
            let savedItem = manifest[path]

            // skip not modified
            guard newItem != savedItem else {
                continue
            }

            switch (newItem, savedItem) {
            case (nil, .some):
                result[path] = .deleted
            case let (.some(item), nil):
                result[path] = .modified(item.hash)
            case let (.some(item), .some):
                result[path] = .modified(item.hash)
            default:
                fatalError("unreachable")
            }
        }

        return result
    }
}

// MARK: CustomStringConvertible

extension Synchronization.ItemStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .deleted: return "deleted"
        case .modified(let hash): return "modified: \(hash.value)"
        }
    }
}
