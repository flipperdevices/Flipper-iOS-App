public struct ArchiveItem: Codable, Equatable, Identifiable {
    public let id: String
    public var name: String
    public var description: String
    public var isFavorite: Bool
    public var kind: Kind
    public var origin: String

    public enum Kind: Codable, Comparable, CaseIterable {
        case ibutton
        case nfc
        case rfid
        case subghz
        case irda
    }

    public init(
        id: String,
        name: String,
        description: String,
        isFavorite: Bool,
        kind: ArchiveItem.Kind,
        origin: String
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.isFavorite = isFavorite
        self.kind = kind
        self.origin = origin
    }
}
