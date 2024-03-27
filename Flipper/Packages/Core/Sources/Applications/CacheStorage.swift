import Peripheral

typealias Cache = ArchiveProtocol

class CacheStorage: FileSystemArchive {
    override func getManifest(
        progress: (Double) -> Void
    ) async throws -> Manifest {
        let path = Path("/ext/apps_manifests")
        let fullPath = root.appending(path)

        let files = try await storage.list(
            at: fullPath,
            calculatingMD5: true,
            sizeLimit: 0
        )
        .files
        .filter { !$0.name.hasPrefix(".") }
        .filter { $0.name.hasSuffix(".fim") }

        var result: [Path: Hash] = [:]
        for file in files {
            result[path.appending(file.name)] = .init(file.md5)
        }
        return .init(result)
    }

    init(storage: FileSystemArchiveAPI) {
        super.init(storage: storage, root: "cache")
    }
}
