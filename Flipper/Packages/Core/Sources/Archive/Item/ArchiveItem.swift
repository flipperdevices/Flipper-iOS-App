import Peripheral
import Foundation

public struct ArchiveItem: Equatable, Identifiable, Hashable {
    public var id: ID {
        .init(path: path)
    }

    public var name: Name
    public let kind: Kind
    public var properties: [Property]
    public var shadowCopy: [Property]
    public var layout: Data?
    public var isFavorite: Bool
    public var status: Status
    public var note: String
    public var date: Date

    public enum Status: Equatable {
        case error
        case deleted
        case imported
        case modified
        case synchronized
        case synchronizing
    }

    public init(
        name: Name,
        kind: Kind,
        properties: [Property],
        shadowCopy: [Property],
        layout: Data? = nil,
        isFavorite: Bool = false,
        status: Status = .imported,
        note: String = "",
        date: Date = .init()
    ) {
        self.name = name
        self.kind = kind
        self.isFavorite = isFavorite
        self.properties = properties
        self.shadowCopy = shadowCopy
        self.layout = layout
        self.status = status
        self.note = note
        self.date = date
    }
}

extension ArchiveItem {
    enum Error: Swift.Error {
        case invalidPath(Path)
        case invalidName(String)
        case invalidType(String)
        case invalidContent(String)
    }

    init(filename: String, data: Data) throws {
        let content = String(decoding: data, as: UTF8.self)
        try self.init(filename: filename, content: content)
    }

    init(path: Path, content: String) throws {
        guard let filename = path.lastComponent else {
            throw Error.invalidPath(path)
        }
        try self.init(filename: filename, content: content)
    }

    init(filename: String, content: String) throws {
        guard let properties = [Property](content: content) else {
            throw Error.invalidContent(filename)
        }
        self = try .init(filename: filename, properties: properties)
    }

    init(
        filename: String,
        properties: [Property],
        shadowCopy: [Property] = []
    ) throws {
        self.init(
            name: try .init(filename: filename),
            kind: try .init(filename: filename),
            properties: properties,
            shadowCopy: shadowCopy)
    }

    public var path: Path {
        .init(components: ["any", kind.location, filename])
    }

    public var filename: String {
        "\(name).\(kind.extension)"
    }
}

extension ArchiveItem {
    public var shadowPath: Path? {
        guard kind == .nfc else { return nil }
        return .init(
            components: [
                "any",
                kind.location,
                "\(name).\(FileType.shadow.extension)"
            ]
        )
    }

    public var layoutPath: Path? {
        return self.path.layoutPath
    }
}

extension ArchiveItem {
    public func rename(to name: Name) -> ArchiveItem {
        .init(
            name: name,
            kind: kind,
            properties: properties,
            shadowCopy: shadowCopy,
            isFavorite: isFavorite)
    }
}

extension Array where Element == ArchiveItem.Property {
    public subscript(key: String) -> String? {
        first { $0.key == key }?.value
    }
}

extension ArchiveItem {
    public var isRaw: Bool {
        properties["Filetype"] == "Flipper SubGhz RAW File"
    }
}

extension ArchiveItem {
    static var allowedCharacters: String {
        #"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"# +
        #"!#\$%&'()-@^_`{}~ "#
    }

    public static func filterInvalidCharacters(
        _ string: any StringProtocol
    ) -> String {
        .init(string.filter { allowedCharacters.contains($0) })
    }
}
