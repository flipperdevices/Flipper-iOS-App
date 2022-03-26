import Bluetooth

class FlipperArchive: FlipperArchiveProtocol {
    let rpc: RPC = .shared

    init() {}

    var manifest: Manifest {
        get async throws {
            try await rpc.manifest
        }
    }

    func read(_ id: ArchiveItem.ID) async throws -> ArchiveItem {
        let bytes = try await rpc.readFile(
            at: id.path,
            priority: .background)
        return try .init(
            path: id.path,
            content: .init(decoding: bytes, as: UTF8.self))
    }

    func upsert(_ item: ArchiveItem) async throws {
        try await rpc.writeFile(
            at: item.id.path,
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
