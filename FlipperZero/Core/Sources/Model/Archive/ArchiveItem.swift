public struct ArchiveItem: Identifiable {
    public let id: String
    public let name: String
    public let description: String
    public let isFavorite: Bool
    public let kind: Kind
    public let origin: String

    public enum Kind {
        case ibutton
        case nfc
        case rfid
        case subghz
    }

    public init(
        id: String,
        name: String,
        description: String,
        isFavorite: Bool,
        kind: ArchiveItem.Kind,
        wut: String
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.isFavorite = isFavorite
        self.kind = kind
        self.origin = wut
    }
}
