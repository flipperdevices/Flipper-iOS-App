class PeripheralArchiveMock: PeripheralArchive {
    func getManifest() async throws -> Manifest {
        .init(items: [])
    }

    func list(at path: Path) async throws -> [Element] {
        []
    }

    func read(at path: Path) async throws -> ArchiveItem? {
        nil
    }

    func write(_ item: ArchiveItem) async {
    }

    func delete(at path: Path) async throws {
    }
}
