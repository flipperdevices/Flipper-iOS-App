import Peripheral

public struct WidgetKey: Equatable, Codable {
    public let name: ArchiveItem.Name
    public let kind: ArchiveItem.Kind

    public init(name: ArchiveItem.Name, kind: ArchiveItem.Kind) {
        self.name = name
        self.kind = kind
    }

    public var path: Path {
        .init(components: ["any", kind.location, filename])
    }

    public var filename: String {
        "\(name).\(kind.extension)"
    }
}
