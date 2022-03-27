import Peripheral

protocol ArchiveProtocol {
    var manifest: Manifest { get async throws }

    func read(_ path: Path) async throws -> String
    func upsert(_ content: String, at path: Path) async throws
    func delete(_ path: Path) async throws
}

protocol FlipperArchiveProtocol: ArchiveProtocol {}
protocol MobileArchiveProtocol: ArchiveProtocol {}
protocol DeletedArchiveProtocol: ArchiveProtocol {}
