import Peripheral

typealias Cache = ArchiveStorage

class CacheStorage: PlainArchiveStorage {
    override var manifest: Manifest {
        get async throws {
            let path = root.appending("ext").appending("apps_manifests")

            guard await storage.isExists(path) else {
                return .init()
            }

            let files = try await storage.list(at: path)
                .filter { !$0.hasPrefix(".") }
                .filter { $0.hasSuffix(".fim") }
                .map { path.appending($0) }

            let items = try await storage.getAllHashes(for: files) { _ in }
            
            var result: [Path: Hash] = [:]
            for (key, value) in items {
                result[key.removingFirstComponent] = value
            }
            return .init(result)
        }
    }

    init() {
        super.init(root: "cache")
    }
}
