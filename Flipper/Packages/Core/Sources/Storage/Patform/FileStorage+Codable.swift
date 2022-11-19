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
        let string = try read(path)
        guard let data = string.data(using: .utf8) else {
            return nil
        }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    func write<T: Codable>(_ value: T, at path: Path) throws {
        let data = try JSONEncoder().encode(value)
        try write(String(decoding: data, as: UTF8.self), at: path)
    }
}
