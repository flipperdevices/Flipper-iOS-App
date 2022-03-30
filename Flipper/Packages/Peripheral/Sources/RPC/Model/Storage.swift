import struct Foundation.Data

public struct StorageSpace: Equatable {
    public let free: Int
    public let total: Int

    public var used: Int { total - free }
}

public enum Element: Equatable {
    case file(File)
    case directory(Directory)

    public var name: String {
        switch self {
        case .file(let file): return file.name
        case .directory(let directory): return directory.name
        }
    }
}

public struct File: Equatable {
    public let name: String
    public let size: Int
    public let data: Data?

    public init(name: String, size: Int, data: Data) {
        self.name = name
        self.size = size
        self.data = data
    }
}

public struct Directory: Equatable {
    public let name: String

    public init(name: String) {
        self.name = name
    }
}

extension StorageSpace {
    init(_ info: PBStorage_InfoResponse) {
        self.free = Int(info.freeSpace)
        self.total = Int(info.totalSpace)
    }
}

extension Element {
    init(_ element: PBStorage_File) {
        switch element.type {
        case .file:
            self = .file(.init(
                name: element.name,
                size: Int(element.size),
                data: element.data))
        case .dir:
            self = .directory(.init(name: element.name))
        default:
            fatalError("unknown storage element type")
        }
    }
}

extension Element: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .file(item): return item.name
        case let .directory(item): return item.name
        }
    }
}

extension Directory: ExpressibleByStringLiteral {
    public init(stringLiteral: String) {
        self.name = stringLiteral
    }
}
