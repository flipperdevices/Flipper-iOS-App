extension ArchiveItem {
    public struct ID: Codable, Equatable, Hashable {
        let name: Name
        let fileType: FileType

        init(name: Name, fileType: FileType) {
            self.name = name
            self.fileType = fileType
        }

        init(path: Path) {
            // swiftlint:disable force_unwrapping
            self.name = .init(fileName: path.components.last!)!
            self.fileType = .init(fileName: path.components.last!)!
        }
    }
}

extension ArchiveItem.ID {
    var path: Path {
        .init(components: ["ext", fileType.location, fileName])
    }

    var fileName: String {
        "\(name).\(fileType.extension)"
    }
}

extension ArchiveItem.ID: CustomStringConvertible {
    public var description: String { fileName }
}
