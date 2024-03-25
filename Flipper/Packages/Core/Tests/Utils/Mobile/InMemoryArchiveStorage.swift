import Core
import Peripheral

class InMemoryArchiveStorage: ArchiveStorage {
    var storage: [Path: String] = [:]

    init() {
    }

    var manifest: Manifest {
        .init(storage.mapValues { .init($0.md5) })
    }

    func get(_ path: Path) async throws -> String {
        guard let content = storage[path] else {
            throw Error.StorageError.doesNotExist
        }
        return content
    }

    func upsert(_ content: String, at path: Path) async throws {
        storage[path] = content
    }
    
    func delete(_ path: Path) async throws {
        guard storage[path] != nil else {
            throw Error.StorageError.doesNotExist
        }
        storage[path] = nil
    }
}
