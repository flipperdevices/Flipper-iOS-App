import Peripheral

class FlipperArchiveMock: FlipperArchiveProtocol {
    func getManifest(progress: (Double) -> Void) async throws -> Manifest {
        .init()
    }

    func read(_ path: Path, progress: (Double) -> Void) async throws -> String {
        fatalError("not implemented")
    }

    func upsert(
        _ content: String,
        at path: Path,
        progress: (Double) -> Void
    ) async throws {
    }

    func delete(_ path: Path) async throws {
    }
}
