import Logging
import Foundation

public struct ArchiveItem: Codable, Equatable, Identifiable {
    public var id: ID { .init(name: name, fileType: fileType) }

    public let name: Name
    public let fileType: FileType
    public var properties: [Property]
    public var isFavorite: Bool
    public var status: Status
    public var date: Date

    public enum Status: Codable, Equatable {
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
        date: Date = .init()
    ) {
        self.name = name
        self.fileType = fileType
        self.isFavorite = isFavorite
        self.properties = properties
        self.status = status
        self.date = date
    }
}

extension ArchiveItem {
    public init?(fileName: String, content: String) {
        let logger = Logger(label: "archiveitem")

        guard let name = Name(fileName: fileName) else {
            logger.error("invalid file name: \(fileName)")
            return nil
        }

        guard let type = FileType(fileName: fileName) else {
            logger.error("invalid file type: \(fileName)")
            return nil
        }

        guard let properties = [Property](content: content) else {
            logger.error("invalid content: \(content)")
            return nil
        }

        self = .init(
            name: name,
            fileType: type,
            properties: properties)
    }

    var path: Path {
        .init(components: ["ext", fileType.location, fileName])
    }

    public var fileName: String {
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
