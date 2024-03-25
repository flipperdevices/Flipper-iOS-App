@testable import Core
@testable import Peripheral
import Foundation

class InMemoryFileSystem {
    var root: Directory

    enum Error: Swift.Error {
        case exists
        case doesNotExist
        case notEmpty
        case invalidName
    }

    enum Entry {
        case file(File)
        case directory(Directory)
    }

    class File {
        private(set) var content: [UInt8]
        private(set) var timestamp: Date

        convenience init(content: String, timestamp: Date = .init()) {
            self.init(content: [UInt8](content.utf8), timestamp: timestamp)
        }

        init(content: [UInt8] = [], timestamp: Date = .init()) {
            self.content = content
            self.timestamp = timestamp
        }

        func read() -> [UInt8] {
            content
        }

        func write(_ bytes: [UInt8]) {
            content += bytes
            timestamp = .now
        }
    }

    class Directory {
        private(set) var entries: [String: Entry]
        private(set) var timestamp: Date

        init(entries: [String: Entry] = [:], timestamp: Date = .init()) {
            self.entries = entries
            self.timestamp = timestamp
        }

        func create(_ name: String, isDirectory: Bool) throws {
            guard entries[name] == nil else {
                throw Error.exists
            }
            entries[name] = isDirectory
                ? .directory(.init())
                : .file(.init())
            timestamp = .now
        }

        func delete(_ name: String, force: Bool) throws {
            guard let entry = entries[name] else {
                throw Error.doesNotExist
            }
            switch entry {
            case .file:
                entries[name] = nil
            case .directory(let directory):
                if directory.entries.isEmpty || force {
                    entries[name] = nil
                } else {
                    throw Error.notEmpty
                }
            }
            timestamp = .now
        }
    }

    init(entries: [String: Entry] = [:]) {
        self.root = .init(
            entries: entries,
            timestamp: .init()
        )
    }

    func isExist(at path: Path) -> Bool {
        entry(at: path) != nil
    }

    private func entry(at path: Path) -> Entry? {
        var result: Entry = .directory(root)

        for component in path.components {
            guard case .directory(let directory) = result else {
                return nil
            }
            guard let entry = directory.entries[component] else {
                return nil
            }
            result = entry
        }

        return result
    }

    func list(at path: Path) throws -> [String: Entry] {
        guard case .directory(let directory) = entry(at: path) else {
            throw Error.doesNotExist
        }
        return directory.entries
    }

    func size(of path: Path) throws -> Int {
        try read(at: path).count
    }

    func hash(of path: Path) throws -> Hash {
        .init(try read(at: path).md5)
    }

    func timestamp(of path: Path) throws -> Date {
        switch entry(at: path) {
        case .file(let file): return file.timestamp
        case .directory(let directory): return directory.timestamp
        case .none: throw Error.doesNotExist
        }
    }

    func create(at path: Path, isDirectory: Bool) throws {
        guard let name = path.lastComponent else {
            throw Error.invalidName
        }
        let base = path.removingLastComponent
        guard case .directory(let directory) = entry(at: base) else {
            throw Error.doesNotExist
        }
        try directory.create(name, isDirectory: isDirectory)
    }

    func delete(at path: Path, force: Bool) throws {
        guard let name = path.lastComponent else {
            throw Error.invalidName
        }
        let base = path.removingLastComponent
        guard case .directory(let directory) = entry(at: base) else {
            throw Error.doesNotExist
        }
        try directory.delete(name, force: force)
    }

    func read(at path: Path) throws -> [UInt8] {
        guard case .file(let file) = entry(at: path) else {
            throw Error.doesNotExist
        }
        return file.content
    }

    func write(at path: Path, bytes: [UInt8]) throws {
        try? delete(at: path, force: false)
        try? create(at: path, isDirectory: false)
        guard case .file(let file) = entry(at: path) else {
            return
        }
        file.write(bytes)
    }

    // TODO: implement moving directories
    func move(at path: Path, to destination: Path) throws {
        guard
            let name = path.lastComponent,
            case .file(let file) = entry(at: path),
            case .directory = entry(at: destination)
        else {
            throw Error.doesNotExist
        }
        let finalPath = destination.appending(name)
        guard !isExist(at: finalPath) else {
            throw Error.exists
        }
        try write(at: finalPath, bytes: file.content)
        try delete(at: path, force: false)
    }
}

extension InMemoryFileSystem.Entry: CustomStringConvertible {
    public var description: String {
        var result = ""
        switch self {
        case .file(let file): result += file.description
        case .directory(let directory): result += "[\(directory.description)]"
        }
        return result
    }
}

extension InMemoryFileSystem.File: CustomStringConvertible {
    public var description: String {
        "\(content.count)"
    }
}

extension InMemoryFileSystem.Directory: CustomStringConvertible {
    public var description: String {
        var result = ""

        for (index, (key, value)) in entries.enumerated() {
            switch value {
            case .file: result += key
            case .directory(let directory): result += "\(key): [\(directory)]"
            }
            if index < entries.count - 1 {
                result.append(", ")
            }
        }
        return result
    }
}
