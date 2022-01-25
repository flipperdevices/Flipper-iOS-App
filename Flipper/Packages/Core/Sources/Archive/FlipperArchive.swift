class FlipperArchive: PeripheralArchiveProtocol {
    let rpc: RPC = .shared

    init() {}

    var manifest: Manifest {
        get async throws {
            try await _manifest
        }
    }

    func read(_ id: ArchiveItem.ID) async throws -> ArchiveItem? {
        let bytes = try await rpc.readFile(
            at: id.path,
            priority: .background)
        return .init(
            fileName: id.fileName,
            content: .init(decoding: bytes, as: UTF8.self),
            status: .imported)
    }

    func upsert(_ item: ArchiveItem) async throws {
        try await rpc.writeFile(
            at: item.path,
            bytes: .init(item.content.utf8),
            priority: .background)
    }

    func delete(_ id: ArchiveItem.ID) async throws {
        try await rpc.deleteFile(
            at: id.path,
            force: false,
            priority: .background)
    }
}
