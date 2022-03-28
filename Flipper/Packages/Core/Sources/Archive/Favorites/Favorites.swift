import Peripheral

public struct Favorites: Codable {
    var items: [Path]

    public var paths: [Path] {
        items
    }

    public init(_ items: [Path] = []) {
        self.items = items
    }

    mutating func upsert(_ path: Path) {
        delete(path)
        items.append(path)
    }

    mutating func delete(_ path: Path) {
        items.removeAll { $0 == path }
    }
}
