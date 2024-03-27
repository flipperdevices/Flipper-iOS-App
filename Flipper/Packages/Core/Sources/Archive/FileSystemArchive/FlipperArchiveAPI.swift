import Peripheral

class FlipperArchiveAPI: FileSystemArchiveAPI {
    let storage: StorageAPI

    init(storage: StorageAPI) {
        self.storage = storage
    }

    func list(
        at path: Path,
        calculatingMD5: Bool,
        sizeLimit: Int
    ) async throws -> [Element] {
        try await FlipperFileListing(storage: storage).list(
            at: path,
            calculatingMD5: calculatingMD5,
            sizeLimit: sizeLimit)
    }

    func createDirectory(at path: Path) async throws {
        try await storage.createDirectory(at: path)
    }

    func read(
        at path: Path,
        progress: (Double) -> Void
    ) async throws -> String {
        try await storage.read(at: path, progress: progress)
    }

    func write(
        at path: Path,
        content: String,
        progress: (Double) -> Void
    ) async throws {
        try await storage.write(at: path, string: content, progress: progress)
    }

    func delete(at path: Path) async throws {
        try await storage.delete(at: path)
    }
}
