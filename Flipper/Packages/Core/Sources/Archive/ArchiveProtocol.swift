import Peripheral
import Foundation

protocol ArchiveProtocol {
    func getManifest(progress: (Double) -> Void) async throws -> Manifest

    func read(_ path: Path, progress: (Double) -> Void) async throws -> String
    func upsert(_ content: String, at path: Path, progress: (Double) -> Void) async throws
    func delete(_ path: Path) async throws
}

extension ArchiveProtocol {
    func getManifest() async throws -> Manifest {
        try await getManifest { _ in }
    }

    func read(_ path: Path) async throws -> String {
        try await read(path) { _ in }
    }

    func upsert(_ content: String, at path: Path) async throws {
        try await upsert(content, at: path) { _ in }
    }

    func nextAvailablePath(for path: Path) async throws -> Path {
        let manifest = try await getManifest()
        guard manifest[path] != nil else {
            return path
        }

        let name = try ArchiveItem.Name(path)
        let type = try ArchiveItem.FileType(path)

        // format: name_{Int}.type
        let parts = name.value.split(separator: "_")

        let namePrefix = parts.count >= 2
            ? parts.dropLast().joined(separator: "_")
            : parts.joined(separator: "_")
        var number = parts.count >= 2
            ? Int(parts.last.unsafelyUnwrapped) ?? 1
            : 1

        var location: Path { path.removingLastComponent }
        var newFileName: String { "\(namePrefix)_\(number).\(type.extension)" }
        var newFilePath: Path { location.appending(newFileName) }

        while manifest[newFilePath] != nil {
            number += 1
        }

        return newFilePath
    }
}

protocol FlipperArchiveProtocol: ArchiveProtocol {}
protocol MobileArchiveProtocol: ArchiveProtocol {
    func compress() -> URL?
}
protocol DeletedArchiveProtocol: ArchiveProtocol {}
