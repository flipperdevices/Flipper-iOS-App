import Peripheral
import Foundation

class FileStorage {
    var baseURL: URL {
        let paths = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask)
        return paths[0]
    }

    init() {}

    func makeDirectory(for path: Path) throws {
        let subdirectory = path.removingLastComponent
        let directory = baseURL.appendingPathComponent(subdirectory.string)
        if !FileManager.default.fileExists(atPath: directory.path) {
            try FileManager.default.createDirectory(
                at: directory,
                withIntermediateDirectories: true)
        }
    }

    private func makeURL(for path: Path) -> URL {
        baseURL.appendingPathComponent(path.string)
    }

    func read(_ path: Path) throws -> String {
        let url = makeURL(for: path)
        return try .init(contentsOf: url)
    }

    func write(_ content: String, at path: Path) throws {
        try makeDirectory(for: path)
        let url = makeURL(for: path)
        try content.write(to: url, atomically: true, encoding: .utf8)
    }

    func delete(_ path: Path) throws {
        let url = makeURL(for: path)
        try FileManager.default.removeItem(at: url)
    }

    func reset() throws {
        let contents = try FileManager
            .default
            .contentsOfDirectory(atPath: baseURL.path)

        for path in contents {
            print(path)
            let url = baseURL.appendingPathComponent(path)
            try FileManager.default.removeItem(at: url)
        }
    }
}

extension URL {
    var isExists: Bool {
        FileManager.default.fileExists(atPath: path)
    }
}
