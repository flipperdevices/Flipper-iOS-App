import Peripheral

struct KnownDirectories {
    var paths: Set<Path> = .init()

    init(_ paths: [Path]) {
        self.paths = .init(paths)
    }

    func contains(_ path: Path) -> Bool {
        paths.contains(path)
    }

    mutating func rememberDirectory(at path: Path) {
        paths.insert(path)
    }
}
