@testable import Core
@testable import Peripheral

class InMemoryArchive: ArchiveProtocol {
    private var storage: CaseInsensitiveStorage = .init()

    private struct CaseInsensitiveStorage {
        var storage: [String: (Path, String?)] = [:]

        var manifest: Manifest {
            var result = Manifest()
            for (_, value) in storage {
                if let content = value.1 {
                    result[value.0] = .init(content.md5)
                }
            }
            return result
        }

        subscript(_ path: Path) -> String? {
            get { storage[path.string.lowercased()]?.1 }
            set { storage[path.string.lowercased()] = (path, newValue) }
        }
    }

    init() {
    }

    func getManifest(
        progress: (Double) -> Void
    ) async throws -> Manifest {
        defer { progress(1.0) }
        return storage.manifest
    }

    func read(
        _ path: Path,
        progress: (Double) -> Void
    ) async throws -> String {
        defer { progress(1.0) }
        guard let content = storage[path] else {
            throw Error.StorageError.doesNotExist
        }
        return content
    }

    func upsert(
        _ content: String,
        at path: Path,
        progress: (Double) -> Void
    ) async throws {
        defer { progress(1.0) }
        storage[path] = content
    }

    func delete(
        _ path: Path
    ) async throws {
        guard storage[path] != nil else {
            throw Error.StorageError.doesNotExist
        }
        storage[path] = nil
    }
}
