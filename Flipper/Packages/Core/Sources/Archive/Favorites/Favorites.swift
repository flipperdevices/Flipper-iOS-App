import Peripheral

public struct Favorites: Codable {
    var items: [Path]

    public var paths: [Path] {
        items
    }

    public init(_ items: [Path] = []) {
        self.items = items
    }

    func contains(_ path: Path) -> Bool {
        items.contains(path)
    }

    mutating func toggle(_ path: Path) {
        switch contains(path) {
        case true: delete(path)
        case false: insert(path)
        }
    }

    private mutating func insert(_ path: Path) {
        items.append(path)
    }

    mutating func upsert(_ path: Path) {
        delete(path)
        insert(path)
    }

    mutating func delete(_ path: Path) {
        items.removeAll { $0 == path }
    }
}
