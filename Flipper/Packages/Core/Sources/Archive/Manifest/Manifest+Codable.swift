extension Manifest: PlaintextCodable {
    init(decoding content: String) throws {
        var manifest: Manifest = .init()
        for line in content.split(separator: "\n") {
            let parts = line.split(separator: ":")
            guard parts.count == 2 else {
                continue
            }
            let path = String(parts[0])
            let hash = String(parts[1])
            manifest[.init(string: path)] = .init(hash)
        }
        self = manifest
    }

    func encode() throws -> String {
        var result: String = ""
        for path in paths {
            if let hash = self[path]?.value {
                result.append("\(path):\(hash)\n")
            }
        }
        return result
    }
}
