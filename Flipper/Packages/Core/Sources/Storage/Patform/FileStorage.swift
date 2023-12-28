import Peripheral
import Foundation

actor FileStorage {
    nonisolated var baseURL: URL {
        // swiftlint:disable force_unwrapping
        FileManager
            .default
            .containerURL(forSecurityApplicationGroupIdentifier: .appGroup)!
        // swiftlint:enable force_unwrapping
    }

    init() {}

    func isExists(_ path: Path) -> Bool {
        makeURL(for: path).isExists
    }

    func isDirectory(_ path: Path) -> Bool {
        makeURL(for: path).isDirectory
    }

    func makeDirectory(for file: Path) throws {
        try makeDirectory(at: file.removingLastComponent)
    }

    func makeDirectory(at path: Path) throws {
        let directory = baseURL.appendingPathComponent(path.string)
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
        var content = ""
        let url = makeURL(for: path)
        var readError: Swift.Error?
        var nsReadError: NSError?
        let coord = NSFileCoordinator(filePresenter: nil)
        coord.coordinate(readingItemAt: url, error: &nsReadError) { readURL in
            do {
                content = try .init(contentsOf: readURL)
            } catch {
                readError = error
            }
        }
        if let error = readError {
            throw error
        }
        if let error = nsReadError {
            throw error
        }
        return content
    }

    func write(_ content: String, at path: Path) throws {
        try makeDirectory(for: path)
        let url = makeURL(for: path)
        var writeError: Swift.Error?
        var nsWriteError: NSError?
        let coord = NSFileCoordinator(filePresenter: nil)
        coord.coordinate(
            writingItemAt: url,
            options: .forReplacing,
            error: &nsWriteError
        ) { writeURL in
            do {
                try content.write(
                    to: writeURL,
                    atomically: true,
                    encoding: .utf8)
            } catch {
                writeError = error
            }
        }
        if let error = writeError {
            throw error
        }
        if let error = nsWriteError {
            throw error
        }
    }

    func append(_ content: String, at path: Path) throws {
        try makeDirectory(for: path)
        let url = makeURL(for: path)
        if !url.isExists {
            FileManager.default.createFile(atPath: url.path, contents: nil)
        }
        let fileHandle = try FileHandle(forWritingTo: url)
        try fileHandle.seekToEnd()
        try fileHandle.write(contentsOf: content.data(using: .utf8) ?? .init())
        try fileHandle.close()
    }

    func delete(_ path: Path) throws {
        let url = makeURL(for: path)
        guard url.isExists else { return }
        try FileManager.default.removeItem(at: url)
    }

    func reset() throws {
        let contents = try FileManager
            .default
            .contentsOfDirectory(atPath: baseURL.path)

        for path in contents {
            let url = baseURL.appendingPathComponent(path)
            try? FileManager.default.removeItem(at: url)
        }
    }

    func list(at path: Path) throws -> [String] {
        let path = baseURL.appendingPathComponent(path.string).path
        return try FileManager.default.contentsOfDirectory(atPath: path)
    }

    func archive(
        _ directory: String = "",
        to archive: String = "archive.zip"
    ) -> URL? {
        var result: URL?
        var error: NSError?

        let sourceURL = baseURL.appendingPathComponent(directory)

        NSFileCoordinator().coordinate(
            readingItemAt: sourceURL,
            options: [.forUploading],
            error: &error
        ) {
            result = try? moveToTemp($0)
        }

        func moveToTemp(_ archiveURL: URL) throws -> URL {
            let tempURL = try FileManager.default.url(
                for: .itemReplacementDirectory,
                in: .userDomainMask,
                appropriateFor: archiveURL,
                create: true
            ).appendingPathComponent(archive)
            try FileManager.default.moveItem(at: archiveURL, to: tempURL)
            return tempURL
        }

        return result
    }
}

extension URL {
    var isExists: Bool {
        FileManager.default.fileExists(atPath: path)
    }

    var isDirectory: Bool {
        var isDirectory: ObjCBool = .init(false)
        _ = FileManager
            .default
            .fileExists(atPath: path, isDirectory: &isDirectory)
        return isDirectory.boolValue
    }
}
