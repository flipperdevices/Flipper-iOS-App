import Peripheral

class MobileFileListing: FileListing {
    let storage: FileStorage

    init(storage: FileStorage) {
        self.storage = storage
    }

    func list(
        at path: Path,
        calculatingMD5: Bool,
        sizeLimit: Int
    ) async throws -> [Element] {
        guard await storage.isExists(path) else {
            return []
        }

        var result: [Element] = []

        let elements = try await storage.list(at: path)
        for name in elements {
            let itemPath = path.appending(name)

            if await storage.isDirectory(itemPath) {
                result.append(.directory(.init(
                    name: name)))
            } else {
                let size = try await storage.size(itemPath)
                guard sizeLimit == 0 || size <= sizeLimit else {
                    continue
                }
                let hash = calculatingMD5
                    ? try await storage.hash(itemPath)
                    : ""
                result.append(.file(.init(
                    name: name,
                    size: size,
                    data: .init(),
                    md5: hash)))
            }
        }

        return result
    }
}
