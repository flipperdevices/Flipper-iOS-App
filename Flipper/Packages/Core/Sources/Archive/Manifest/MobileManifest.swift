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
        let paths = try await listAllFiles(
            recursively: true,
            at: root
        ) { listingProgress in
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
        recursively: Bool = false,
        at root: Path,
        progress: (Double) -> Void
    ) async throws -> [Path] {
        var result: [Path] = .init()
        progress(0)
        for (index, type) in FileType.allCases.enumerated() {
            let path = root.appending(type.location)
            let files = try await listFiles(
                at: path,
                matching: type,
                recursively: recursively
            )
            result.append(contentsOf: files)
            progress(Double(index + 1) / Double(FileType.allCases.count))
        }
        return result
    }

    private func listFiles(
        at path: Path,
        matching fileType: FileType,
        recursively: Bool = false
    ) async throws -> [Path] {
        var result: [Path] = .init()

        let elements = try await listAsync(at: path)
            .filter { !$0.hasPrefix(".") }
            .map { path.appending($0) }

        let files = elements.filter { path in
            path.string.hasSuffix(fileType.extension)
        }
        result.append(contentsOf: files)

        guard recursively else { return result }
        for directory in elements.filter({ isValidDirectory($0)} ) {
            let recursiveElements = try await listFiles(
                at: directory,
                matching: fileType,
                recursively: recursively
            )
            result.append(contentsOf: recursiveElements)
        }
        return result
    }

    private func listAsync(at path: Path) async throws -> [String] {
        guard isExists(path) else {
            return []
        }
        var result: [String] = .init()
        let elements = try list(at: path)
        for element in elements {
            let path = Path(string: element)
            guard !isDirectory(path) else {
                result.append(contentsOf: try await listAsync(at: path))
                return result
            }
            result.append(element)
        }
        return result
    }

    private func getAllHashes(
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

    private func isValidDirectory(_ path: Path) -> Bool {
        guard
            isDirectory(path),
            let lastComponent = path.lastComponent
        else { return false }
        return lastComponent != String.ignoredDirectory
    }
}
