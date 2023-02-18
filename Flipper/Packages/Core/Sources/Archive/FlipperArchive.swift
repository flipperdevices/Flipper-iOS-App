import Peripheral

class FlipperArchive: FlipperArchiveProtocol {
    private let pairedDevice: PairedDevice
    private var rpc: RPC { pairedDevice.session }

    init(pairedDevice: PairedDevice) {
        self.pairedDevice = pairedDevice
    }

    func getManifest(progress: (Double) -> Void) async throws -> Manifest {
        try await rpc.getManifest(progress: progress)
    }

    func read(_ path: Path, progress: (Double) -> Void) async throws -> String {
        try await rpc.readFile(at: path, progress: progress)
    }

    func upsert(
        _ content: String,
        at path: Path,
        progress: (Double) -> Void
    ) async throws {
        try await rpc.writeFile(at: path, string: content, progress: progress)
    }

    func delete(_ path: Path) async throws {
        try await rpc.deleteFile(at: path)
    }
}
