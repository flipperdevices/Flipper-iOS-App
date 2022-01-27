extension ArchiveItem {
    public struct Name: Codable, Equatable, Hashable {
        public var value: String

        public init<T: StringProtocol>(_ value: T) {
            self.value = String(value)
        }
    }
}

extension ArchiveItem.Name {
    init?<T: StringProtocol>(fileName: T) {
        guard let name = fileName.split(separator: ".").first else {
            return nil
        }
        self.value = String(name)
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

extension ArchiveItem.Name: Comparable {
    public static func < (
        lhs: ArchiveItem.Name,
        rhs: ArchiveItem.Name
    ) -> Bool {
        lhs.value < rhs.value
    }
}
