protocol ArchiveProtocol {
    var manifest: Manifest { get async throws }

    func read(_ id: ArchiveItem.ID) async throws -> ArchiveItem?
    func upsert(_ item: ArchiveItem) async throws
    func delete(_ id: ArchiveItem.ID) async throws
}

protocol PeripheralArchiveProtocol: ArchiveProtocol {}
protocol MobileArchiveProtocol: ArchiveProtocol {}
protocol DeletedArchiveProtocol: ArchiveProtocol {}
