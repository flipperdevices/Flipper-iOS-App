class MobileArchiveMock: MobileArchiveProtocol {
    var manifest: Manifest { .init(items: []) }

    func read(_ id: ArchiveItem.ID) async throws -> ArchiveItem? {
        nil
    }

    func upsert(_ item: ArchiveItem) async throws {
    }

    func delete(_ id: ArchiveItem.ID) async throws {
    }
}
