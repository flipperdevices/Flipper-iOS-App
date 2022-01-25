public struct Manifest: Codable {
    var items: [Item]

    public struct Item: Equatable, Codable {
        public let id: ArchiveItem.ID
        public let hash: Hash
    }

    subscript(_ id: ArchiveItem.ID) -> Item? {
        return items.first { $0.id == id }
    }
}
