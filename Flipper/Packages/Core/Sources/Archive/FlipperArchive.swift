import Peripheral

class FlipperArchive: ArchiveProtocol {
    private let storage: StorageAPI
    private let manifest: FileSystemManifest
    private var knownDirectories: KnownDirectories

    init(storage: StorageAPI) {
        self.storage = storage
        self.manifest = FileSystemManifest(listing: FlipperFileListing(
            storage: storage,
            root: "/any"))
        self.knownDirectories = .init([])
    }

    func getManifest(progress: (Double) -> Void) async throws -> Manifest {
        let (manifest, direcrories) = try await manifest.get(progress: progress)
        self.knownDirectories = direcrories
        return manifest.appendingPrefix("/any")
    }

    func read(_ path: Path, progress: (Double) -> Void) async throws -> String {
        try await storage.read(at: path, progress: progress)
    }

    func upsert(
        _ content: String,
        at path: Path,
        progress: (Double) -> Void
    ) async throws {
        await createDirectoryIfNeeded(at: path.removingLastComponent)
        try await storage.write(at: path, string: content, progress: progress)
    }

    func delete(_ path: Path) async throws {
        try await storage.delete(at: path)
    }

    private func createDirectoryIfNeeded(at path: Path) async {
        if !knownDirectories.contains(path) {
            try? await storage.createDirectory(at: path)
            knownDirectories.rememberDirectory(at: path)
        }
    }
}
