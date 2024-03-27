import Peripheral
import Foundation

class MobileArchive: FileSystemArchive {
    private var _manifest: Manifest?

    init(storage: FileSystemArchiveAPI) {
        super.init(storage: storage, root: "mobile")
    }

    override func getManifest(
        progress: (Double) -> Void
    ) async throws -> Manifest {
        if let manifest = _manifest {
            progress(1.0)
            return manifest
        } else {
            let manifest = try await super.getManifest(progress: progress)
            self._manifest = manifest
            return manifest
        }
    }

    override func upsert(
        _ content: String,
        at path: Path,
        progress: (Double) -> Void
    ) async throws {
        try await super.upsert(content, at: path, progress: progress)
        _manifest?[path] = .init(content.md5)
    }

    override func delete(_ path: Path) async throws {
        try await super.delete(path)
        _manifest?[path] = nil
    }
}

extension MobileArchive: Compressable {
    func compress() async -> URL? {
        guard let storage = storage as? FileStorage else {
            return nil
        }
        return await storage.archive("mobile")
    }
}
