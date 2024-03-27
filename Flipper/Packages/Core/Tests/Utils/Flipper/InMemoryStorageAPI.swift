@testable import Core
@testable import Peripheral
import Foundation

class InMemoryStorageAPI: StorageAPI, FileSystemArchiveAPI {
    var fileSystem: InMemoryFileSystem

    convenience init() {
        self.init(
            entries: [
                "any": .directory(.init(entries: [:], timestamp: .init())),
                "int": .directory(.init(entries: [:], timestamp: .init())),
                "ext": .directory(.init(entries: [:], timestamp: .init()))
            ]
        )
    }

    init(entries: [String: InMemoryFileSystem.Entry]) {
        self.fileSystem = .init(entries: entries)
    }

    func space(of path: Path) async throws -> StorageSpace {
        path == "int"
            ? .init(free: 228 * 1024 - 28, total: 228 * 1024)
            : .init(free: 128 * 1024 * 1024, total: 256 * 1024 * 1024)
    }

    func list(
        at path: Path,
        calculatingMD5: Bool,
        sizeLimit: Int
    ) async throws -> [Element] {
        do {
            return try fileSystem.list(at: path).compactMap {
                switch $0.value {
                case .file(let file):
                    guard
                        sizeLimit == 0 ||
                        file.content.count <= sizeLimit
                    else {
                        return nil
                    }
                    return .file(.init(
                        name: $0.key,
                        size: file.content.count,
                        data: .init(),
                        md5: calculatingMD5 ? file.content.md5 : ""))
                case .directory:
                    return .directory(.init(
                        name: $0.key))
                }
            }
        } catch {
            throw Error.StorageError(error)
        }
    }

    func size(of path: Path) async throws -> Int {
        do {
            return try fileSystem.size(of: path)
        } catch {
            throw Error.StorageError(error)
        }
    }

    func hash(of path: Path) async throws -> Hash {
        do {
            return try fileSystem.hash(of: path)
        } catch {
            throw Error.StorageError(error)
        }
    }

    func timestamp(of path: Path) async throws -> Date {
        do {
            return try fileSystem.timestamp(of: path)
        } catch {
            throw Error.StorageError(error)
        }
    }

    func create(at path: Path, isDirectory: Bool) async throws {
        do {
            try fileSystem.create(at: path, isDirectory: isDirectory)
        } catch {
            throw Error.StorageError(error)
        }
    }

    func delete(at path: Path, force: Bool) async throws {
        do {
            try fileSystem.delete(at: path, force: force)
        } catch {
            throw Error.StorageError(error)
        }
    }

    func read(at path: Path) -> ByteStream {
        .init { continuation in
            do {
                let bytes = try fileSystem.read(at: path)
                // TODO: chunk by ~512 bytes
                continuation.yield(bytes)
                continuation.finish()
            } catch {
                continuation.finish(throwing: Error.StorageError(error))
            }
        }
    }

    func write(at path: Path, bytes: [UInt8]) -> ByteCountStream {
        .init { continuation in
            do {
                try fileSystem.write(at: path, bytes: bytes)
                // TODO: chunk by ~512 bytes
                continuation.yield(bytes.count)
                continuation.finish()
            } catch {
                continuation.finish(throwing: Error.StorageError(error))
            }
        }
    }

    func move(at path: Path, to destination: Path) async throws {
        do {
            try fileSystem.move(at: path, to: destination)
        } catch {
            throw Error.StorageError(error)
        }
    }
}

extension InMemoryStorageAPI {
    func delete(at path: Path) async throws {
        try await self.delete(at: path, force: false)
    }

    func write(
        at path: Path,
        content: String,
        progress: (Double) -> Void
    ) async throws {
        try await write(at: path, string: content, progress: progress)
    }
}

private extension Error.StorageError {
    init(_ source: Swift.Error) {
        if let error = source as? InMemoryFileSystem.Error {
            self = Error.StorageError(error)
        } else {
            self = Error.StorageError.internal
        }
    }

    init(_ source: InMemoryFileSystem.Error) {
        switch source {
        case .exists: self = .exists
        case .doesNotExist: self = .doesNotExist
        case .notEmpty: self = .notEmpty
        case .invalidName: self = .invalidName
        }
    }
}
