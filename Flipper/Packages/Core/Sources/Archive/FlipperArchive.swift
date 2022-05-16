import Inject
import Peripheral

class FlipperArchive: FlipperArchiveProtocol {
    @Inject var rpc: RPC

    init() {}

    var manifest: Manifest {
        get async throws {
            try await rpc.manifest
        }
    }

    func read(_ path: Path) async throws -> String {
        let bytes = try await rpc.readFile(at: path)
        return .init(decoding: bytes, as: UTF8.self)
    }

    func upsert(_ content: String, at path: Path) async throws {
        try await rpc.writeFile(at: path, bytes: .init(content.utf8))
    }

    func delete(_ path: Path) async throws {
        try await rpc.deleteFile(at: path)
    }
}
