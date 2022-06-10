import Peripheral
import Foundation

class MobileArchiveMock: MobileArchiveProtocol {
    func getManifest(progress: (Double) -> Void) async throws -> Manifest {
        .init()
    }

    func read(_ path: Path) async throws -> String {
        fatalError("not implemented")
    }

    func upsert(_ content: String, at path: Path) async throws {
    }

    func delete(_ path: Path) async throws {
    }

    func compress() -> URL? {
        nil
    }
}
