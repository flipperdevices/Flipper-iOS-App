import struct Peripheral.Path

extension ArchiveItem {
    public struct Name: Equatable, Hashable {
        public var value: String

        public init<T: StringProtocol>(_ value: T) {
            self.value = String(value)
        }
    }
}

extension ArchiveItem.Name {
    init<T: StringProtocol>(filename: T) throws {
        guard let name = filename.split(separator: ".").first else {
            throw ArchiveItem.Error.invalidName(String(filename))
        }
        self.value = String(name)
    }
}

extension ArchiveItem.Name {
    init(_ path: Path) throws {
        guard let filename = path.lastComponent else {
            throw ArchiveItem.Error.invalidPath(path)
        }
        try self.init(filename: filename)
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
