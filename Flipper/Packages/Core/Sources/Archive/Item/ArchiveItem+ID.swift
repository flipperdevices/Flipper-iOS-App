extension ArchiveItem {
    public struct ID: Codable, Equatable, Hashable {
        let name: Name
        let fileType: FileType

        init(name: Name, fileType: FileType) {
            self.name = name
            self.fileType = fileType
        }

        init(path: Path) throws {
            guard let filename = path.components.last else {
                throw Error.invalidName
            }
            self.name = try .init(filename: filename)
            self.fileType = try .init(filename: filename)
        }
    }
}

extension ArchiveItem.ID {
    var path: Path {
        // FIXME: Use relative path as ID, move root dir to RPC
        .init(components: ["ext", fileType.location, filename])
    }

    var filename: String {
        "\(name).\(fileType.extension)"
    }
}

extension ArchiveItem.ID: CustomStringConvertible {
    public var description: String { filename }
}
