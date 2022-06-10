import Peripheral
import Foundation

protocol ArchiveProtocol {
    func getManifest(progress: (Double) -> Void) async throws -> Manifest

    func read(_ path: Path) async throws -> String
    func upsert(_ content: String, at path: Path) async throws
    func delete(_ path: Path) async throws
}

extension ArchiveProtocol {
    func getManifest() async throws -> Manifest {
        try await getManifest(progress: {_ in })
    }
}

protocol FlipperArchiveProtocol: ArchiveProtocol {}
protocol MobileArchiveProtocol: ArchiveProtocol {
    func compress() -> URL?
}
protocol DeletedArchiveProtocol: ArchiveProtocol {}
