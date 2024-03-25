import Peripheral
import Foundation

class PlainArchiveStorage: ArchiveStorage {
    let storage: FileStorage = .init()
    let fsManifest: FileSystemManifest

    let root: Path

    init(root: Path) {
        self.root = root
        self.fsManifest = .init(listing: MobileFileListing(
            storage: storage,
            root: root.appending("any")
        ))
    }

    var manifest: Manifest {
        get async throws {
            let (manifest, _) = try await fsManifest.get { _ in }
            return manifest.appendingPrefix("/any")
        }
    }

    func get(_ path: Path) async throws -> String {
        let path = makePath(for: path)
        return try await storage.read(path)
    }

    func upsert(_ content: String, at path: Path) async throws {
        let path = makePath(for: path)
        try await storage.write(content, at: path)
    }

    func delete(_ path: Path) async throws {
        let path = makePath(for: path)
        try await storage.delete(path)
    }

    private func makePath(for path: Path) -> Path {
        root.appending(path)
    }
}

extension PlainArchiveStorage: Compressable {
    func compress() async -> URL? {
        let name = root.lastComponent ?? "archive"
        return await storage.archive(root.string, to: "\(name).zip")
    }
}
