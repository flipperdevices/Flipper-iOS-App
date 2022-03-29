import Peripheral

extension FileStorage {
    func read<T: PlaintextCodable>(_ path: Path) throws -> T {
        try .init(decoding: read(path))
    }

    func write<T: PlaintextCodable>(_ value: T, at path: Path) throws {
        try write(value.encode(), at: path)
    }
}
