import Peripheral

protocol FileSystemArchiveAPI: FileListing {
    func list(
        at path: Path,
        calculatingMD5: Bool,
        sizeLimit: Int
    ) async throws -> [Element]

    func createDirectory(
        at path: Path
    ) async throws

    func read(
        at path: Path,
        progress: (Double) -> Void
    ) async throws -> String

    func write(
        at path: Path,
        content: String,
        progress: (Double) -> Void
    ) async throws

    func delete(
        at path: Path
    ) async throws
}
