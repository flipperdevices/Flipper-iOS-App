import Peripheral

public struct Manifest {
    var items: [Path: Hash]

    public var paths: Dictionary<Path, Hash>.Keys {
        items.keys
    }

    public init(_ items: [Path: Hash] = [:]) {
        self.items = items
    }

    public subscript(_ path: Path) -> Hash? {
        get { items[path] }
        set { items[path] = newValue }
    }
}

extension Manifest {
    // TODO: Remove
    // NOTE: Temporary hack
    func appendingPrefix(_ path: Path) -> Manifest {
        var result: [Path: Hash] = [:]
        for (key, value) in items {
            result[path.appending(key)] = value
        }
        return .init(result)
    }
}
