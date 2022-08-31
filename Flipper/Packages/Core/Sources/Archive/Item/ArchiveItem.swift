import Logging
import Peripheral
import Foundation

public struct ArchiveItem: Equatable, Identifiable {
    public var id: ID {
        .init(path: path)
    }

    public var name: Name
    public let fileType: FileType
    public var properties: [Property]
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
        fileType: FileType,
        properties: [Property],
        isFavorite: Bool = false,
        status: Status = .imported,
        note: String = "",
        date: Date = .init()
    ) {
        self.name = name
        self.fileType = fileType
        self.isFavorite = isFavorite
        self.properties = properties
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

    init(filename: String, properties: [Property]) throws {
        self.init(
            name: try .init(filename: filename),
            fileType: try .init(filename: filename),
            properties: properties)
    }

    public var path: Path {
        .init(components: ["any", fileType.location, filename])
    }

    var filename: String {
        "\(name).\(fileType.extension)"
    }
}

extension ArchiveItem {
    public func rename(to name: Name) -> ArchiveItem {
        .init(
            name: name,
            fileType: fileType,
            properties: properties)
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
