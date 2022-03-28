import Peripheral

class PlainManifestStorage {
    let storage: FileStorage = .init()

    func read(_ path: Path) throws -> Manifest {
        var manifest: Manifest = .init()
        guard let content = try? storage.read(path) else {
            return manifest
        }
        for line in content.split(separator: "\n") {
            let parts = line.split(separator: ":")
            guard parts.count == 2 else {
                continue
            }
            let path = String(parts[0])
            let hash = String(parts[1])
            manifest[.init(string: path)] = .init(hash)
        }
        return manifest
    }

    func write(_ manifest: Manifest, at path: Path) throws {
        var result: String = ""
        for path in manifest.paths {
            if let hash = manifest[path]?.value {
                result.append("\(path):\(hash)\n")
            }
        }
        try? storage.write(content: result, to: path)
    }

    func delete(_ path: Path) throws {
        try storage.delete(path)
    }
}
