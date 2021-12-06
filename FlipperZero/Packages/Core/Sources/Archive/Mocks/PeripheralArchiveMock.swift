class PeripheralArchiveMock: PeripheralArchive {
    var root: Path {
        .init(string: "/")
    }

    var directories: [Path] {
        []
    }

    func getFileHash(at path: Path) async throws -> Hash {
        .init("")
    }

    func list(at path: Path) async throws -> [Element] {
        []
    }

    func read(at path: Path) async throws -> ArchiveItem? {
        nil
    }

    func write(_ item: ArchiveItem, at path: Path) async {
    }

    func delete(at path: Path) async throws {
    }
}
