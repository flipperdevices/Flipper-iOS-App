public enum Element {
    case file(File)
    case directory(Directory)
}

public struct File {
    public let name: String
    public let size: Int

    public init(name: String, size: Int) {
        self.name = name
        self.size = size
    }
}

public struct Directory {
    public let name: String

    public init(name: String) {
        self.name = name
    }
}

extension Element {
    init(_ element: PBStorage_Element) {
        switch element.type {
        case .file:
            self = .file(.init(name: element.name, size: Int(element.size)))
        case .dir:
            self = .directory(.init(name: element.name))
        default:
            fatalError("unknown storage element type")
        }
    }
}
