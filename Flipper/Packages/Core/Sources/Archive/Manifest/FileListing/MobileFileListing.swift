import Peripheral

class MobileFileListing: FileListing {
    let storage: FileStorage
    let root: Path

    init(storage: FileStorage, root: Path) {
        self.storage = storage
        self.root = root
    }

    func list(
        at path: Path,
        calculatingMD5: Bool,
        sizeLimit: Int
    ) async throws -> [Element] {
        let path = root.appending(path)
        guard await storage.isExists(path) else {
            return []
        }

        var result: [Element] = []

        for name in try await storage.list(at: path) {
            let itemPath = path.appending(name)
            
            if await storage.isDirectory(itemPath) {
                result.append(.directory(.init(
                    name: name)))
            } else {
                let size = try await storage.size(itemPath)
                guard sizeLimit == 0 || size <= sizeLimit else {
                    continue
                }
                result.append(.file(await .init(
                    name: name,
                    size: size,
                    data: .init(),
                    md5: calculatingMD5 ? try storage.hash(itemPath) : "")))
            }
        }

        return result
    }
}
