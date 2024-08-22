import Infrared

public struct InfraredFile: Equatable, Hashable {
    public let id: Int
    public let name: String

    public var idStr: String {
        String(id)
    }

    init(_ file: Infrared.InfraredFile) {
        self.id = file.id
        self.name = file.folderName
    }

    public init (id: Int, name: String) {
        self.id = id
        self.name = name
    }
}
