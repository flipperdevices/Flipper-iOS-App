import Bluetooth

extension Sync {
    enum ItemStatus: Equatable {
        case deleted
        case modified(Hash)
    }
}

// MARK: Manifest changes

extension Manifest {
    func changesSince(
        _ manifest: Manifest
    ) -> [Path: Sync.ItemStatus] {
        var result: [Path: Sync.ItemStatus] = [:]

        let paths = Set(self.paths)
            .union(manifest.paths)

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
            case let (.some(hash), nil):
                result[path] = .modified(hash)
            case let (.some(hash), .some):
                result[path] = .modified(hash)
            default:
                fatalError("unreachable")
            }
        }

        return result
    }
}

// MARK: CustomStringConvertible

extension Sync.ItemStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .deleted: return "deleted"
        case .modified(let hash): return "modified: \(hash.value)"
        }
    }
}
