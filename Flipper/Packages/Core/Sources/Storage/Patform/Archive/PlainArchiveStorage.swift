import Peripheral
import Foundation

class PlainArchiveStorage: ArchiveStorage {
    let storage: FileStorage = .init()

    let root: Path

    init(root: Path) {
        self.root = root
    }

    var manifest: Manifest {
        get async throws {
            try await storage.getManifest(at: root)
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
        root.appending(path.string)
    }
}

extension PlainArchiveStorage: Compressable {
    func compress() async -> URL? {
        let name = root.lastComponent ?? "archive"
        return await storage.archive(root.string, to: "\(name).zip")
    }
}
