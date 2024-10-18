import Peripheral
import Foundation

extension FileStorage {
    func read<T: PlaintextCodable>(_ path: Path) throws -> T {
        try .init(decoding: read(path))
    }

    func write<T: PlaintextCodable>(_ value: T, at path: Path) throws {
        try write(value.encode(), at: path)
    }
}

extension FileStorage {
    func read<T: Codable>(_ path: Path) throws -> T? {
        return try? JSONDecoder().decode(T.self, from: read(path))
    }

    func write<T: Codable>(_ value: T, at path: Path) throws {
        let data = try JSONEncoder().encode(value)
        try write(try data.utf8String, at: path)
    }
}
