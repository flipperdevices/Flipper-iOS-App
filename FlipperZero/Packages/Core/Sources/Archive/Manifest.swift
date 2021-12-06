public struct Manifest: Codable {
    var items: [Item]

    public struct Item: Equatable, Codable {
        public let path: Path
        public let hash: Hash
    }

    subscript(_ path: Path) -> Item? {
        return items.first { $0.path == path }
    }
}
