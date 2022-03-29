import Peripheral

extension ArchiveItem {
    public struct ID: Codable, Equatable, Hashable {
        let path: Path

        init(path: Path) {
            self.path = path
        }
    }
}

extension ArchiveItem.ID: CustomStringConvertible {
    public var description: String { path.description }
}
