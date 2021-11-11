public struct ArchiveItem: Codable, Equatable, Identifiable {
    public let id: String
    public var name: Name
    public var fileType: FileType
    public var properties: [Property]
    public var isFavorite: Bool

    public struct Name: Codable, Equatable {
        public var value: String
    }

    public struct Property: Codable, Equatable {
        public let key: String
        public var value: String
        public var description: [String] = []
    }

    public enum FileType: Codable, Comparable, CaseIterable {
        case ibutton
        case nfc
        case rfid
        case subghz
        case irda
    }

    public init(
        id: ID,
        name: Name,
        fileType: FileType,
        properties: [Property],
        isFavorite: Bool = false
    ) {
        self.id = id
        self.name = name
        self.fileType = fileType
        self.isFavorite = isFavorite
        self.properties = properties
    }
}

extension ArchiveItem.Name: CustomStringConvertible {
    public var description: String {
        value
    }
}

extension ArchiveItem.Name: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.value = value
    }
}
