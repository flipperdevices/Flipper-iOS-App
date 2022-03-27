import Inject
import Bluetooth
import Foundation

class PlainDeletedArchiveStorage: DeletedArchiveStorage {
    let storage: FileStorage = .init()

    init() {}

    func get(_ path: Path) async throws -> String {
        let path = makePath(for: path)
        return try storage.read(path)
    }

    func upsert(_ content: String, at path: Path) async throws {
        let path = makePath(for: path)
        try storage.write(content: content, to: path)
    }

    func delete(_ path: Path) async throws {
        let path = makePath(for: path)
        try storage.delete(path)
    }

    private func makePath(for path: Path) -> Path {
        .init(string: "/deleted/\(path.string)")
    }
}
