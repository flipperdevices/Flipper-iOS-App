import Infrared

public struct InfraredFile: Equatable, Hashable {
    public let id: Int
    public let fileName: String

    public init(_ file: Infrared.InfraredFile) {
        self.id = file.id
        self.fileName = file.fileName
    }
}
