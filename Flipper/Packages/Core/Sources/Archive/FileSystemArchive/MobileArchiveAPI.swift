import Peripheral

extension FileStorage: FileSystemArchiveAPI {
    func list(
        at path: Path,
        calculatingMD5: Bool,
        sizeLimit: Int
    ) async throws -> [Element] {
        try await MobileFileListing(storage: self).list(
            at: path,
            calculatingMD5: calculatingMD5,
            sizeLimit: sizeLimit)
    }

    func createDirectory(at path: Path) async throws {
        try self.makeDirectory(at: path)
    }

    func read(
        at path: Path,
        progress: (Double) -> Void
    ) async throws -> String {
        defer { progress(1.0) }
        return try read(path)
    }

    func write(
        at path: Path,
        content: String,
        progress: (Double) -> Void
    ) async throws {
        defer { progress(1.0) }
        try write(content, at: path)
    }

    func delete(at path: Path) async throws {
        try delete(path)
    }
}
