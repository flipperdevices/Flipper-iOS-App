import Peripheral
import Foundation

extension FileStorage {
    func getManifest(at root: Path) async throws -> Manifest {
        try await getManifest(at: root) { _ in }
    }

    func getManifest(
        at root: Path,
        progress: (Double) -> Void
    ) async throws -> Manifest {
        let root = root.appending("any")
        let paths = try await listAllFiles(at: root) { listingProgress in
            progress(listingProgress / 2)
        }

        let hashes = try await getAllHashes(for: paths) { hashingProgress in
            progress(0.5 + hashingProgress / 2)
        }

        var result: Manifest = .init()
        for hash in hashes {
            result.items[hash.key.removingFirstComponent] = hash.value
        }
        return result
    }

    private func listAllFiles(
        at root: Path,
        progress: (Double) -> Void
    ) async throws -> [Path] {
        var result: [Path] = .init()

        progress(0)

        for (index, type) in FileType.allCases.enumerated() {
            let path = root.appending(type.location)

            let files = try await listFiles(at: path)
                .filter { !$0.hasPrefix(".") }
                .filter { $0.hasSuffix(type.extension) }
                .map { path.appending($0) }

            result.append(contentsOf: files)

            progress(Double(index + 1) / Double(FileType.allCases.count))
        }

        return result
    }

    private func listFiles(at path: Path) async throws -> [String] {
        guard isExists(path) else {
            return []
        }
        return try list(at: path).compactMap { child in
            guard !isDirectory(child) else {
                return nil
            }
            return child.string
        }
    }

    func getAllHashes(
        for paths: [Path],
        progress: (Double) -> Void
    ) async throws -> [Path: Hash] {
        var items = [Path: Hash]()

        progress(0)

        for (index, path) in paths.enumerated() {
            items[path] = try await getFileHash(at: path)
            progress(Double(index + 1) / Double(paths.count))
        }

        return items
    }

    private func getFileHash(at path: Path) async throws -> Hash {
        try .init(read(path).md5)
    }
}
