import Inject
import Peripheral

class FlipperArchive: FlipperArchiveProtocol {
    @Inject var rpc: RPC

    init() {}

    func getManifest(progress: (Double) -> Void) async throws -> Manifest {
        try await rpc.getManifest(progress: progress)
    }

    func read(_ path: Path, progress: (Double) -> Void) async throws -> String {
        let size = try await rpc.getSize(at: path)
        var bytes: [UInt8] = []
        for try await next in rpc.readFile(at: path) {
            bytes += next
            progress(Double(bytes.count) / Double(size))
        }
        return .init(decoding: bytes, as: UTF8.self)
    }

    func upsert(
        _ content: String,
        at path: Path,
        progress: (Double) -> Void
    ) async throws {
        let bytes = [UInt8](content.utf8)
        var sent = 0
        for try await next in rpc.writeFile(at: path, bytes: bytes) {
            sent += next
            progress(Double(sent) / Double(bytes.count))
        }
    }

    func delete(_ path: Path) async throws {
        try await rpc.deleteFile(at: path)
    }
}
