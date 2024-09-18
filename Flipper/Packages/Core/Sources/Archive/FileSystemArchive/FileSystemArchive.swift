import Peripheral
import Foundation

class FileSystemArchive: ArchiveProtocol {
    let storage: FileSystemArchiveAPI
    let root: Path

    var manifest: FileSystemManifest { .init(listing: storage) }
    var knownDirectories: KnownDirectories = .init([])

    init(storage: FileSystemArchiveAPI, root: Path) {
        self.storage = storage
        self.root = root
    }

    func getManifest(
        progress: (Double) -> Void
    ) async throws -> Manifest {
        let (manifest, direcrories) = try await manifest.get(
            at: root.appending("ext"),
            progress: progress
        )
        self.knownDirectories = direcrories
        return inserting("/ext", to: manifest)
    }

    // TODO: Remove
    // NOTE: Temporary hack
    private func inserting(_ path: Path, to manifest: Manifest) -> Manifest {
        var result: [Path: Hash] = [:]
        for (key, value) in manifest.items {
            result[path.appending(key)] = value
        }
        return .init(result)
    }

    func read(
        _ path: Path,
        progress: (Double) -> Void
    ) async throws -> String {
        let path = makePath(for: path)
        return try await storage.read(at: path, progress: progress)
    }

    func upsert(
        _ content: String,
        at path: Path,
        progress: (Double) -> Void
    ) async throws {
        let path = makePath(for: path)
        await createDirectoryIfNeeded(at: path.removingLastComponent)
        try await storage.write(at: path, content: content, progress: progress)
    }

    func delete(
        _ path: Path
    ) async throws {
        let path = makePath(for: path)
        try await storage.delete(at: path)
    }

    private func makePath(for path: Path) -> Path {
        root.appending(path)
    }

    private func createDirectoryIfNeeded(at path: Path) async {
        if !knownDirectories.contains(path) {
            try? await storage.createDirectory(at: path)
            knownDirectories.rememberDirectory(at: path)
        }
    }
}
