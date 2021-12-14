protocol PeripheralArchive {
    func getManifest() async throws -> Manifest

    func list(at path: Path) async throws -> [Element]
    func read(at path: Path) async throws -> ArchiveItem?
    func write(_ item: ArchiveItem) async throws
    func delete(at path: Path) async throws
}
