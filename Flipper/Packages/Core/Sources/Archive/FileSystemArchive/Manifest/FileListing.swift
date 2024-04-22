import Peripheral

protocol FileListing {
    func list(
        at path: Path,
        calculatingMD5: Bool,
        sizeLimit: Int
    ) async throws -> [Element]
}
