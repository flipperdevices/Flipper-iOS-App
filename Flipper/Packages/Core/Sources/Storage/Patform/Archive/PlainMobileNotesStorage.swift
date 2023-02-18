import Peripheral
import Foundation

class PlainMobileNotesStorage: MobileNotesStorage {
    let storage: FileStorage = .init()
    private let root: Path = "notes"

    var manifest: Manifest {
        get async throws {
            try await storage.getManifest(at: root)
        }
    }

    init() {}

    func get(_ path: Path) async throws -> String {
        let path = makePath(for: path)
        return try storage.read(path)
    }

    func upsert(_ content: String, at path: Path) async throws {
        let path = makePath(for: path)
        try storage.write(content, at: path)
    }

    func delete(_ path: Path) async throws {
        let path = makePath(for: path)
        try storage.delete(path)
    }

    private func makePath(for path: Path) -> Path {
        root.appending(path.string)
    }
}
