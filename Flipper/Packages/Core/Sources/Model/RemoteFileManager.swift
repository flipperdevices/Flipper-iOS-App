import Peripheral

import Combine
import Foundation

@MainActor
public class RemoteFileManager: ObservableObject {
    private let storage: StorageAPI

    private var supportedExtensions: [String] = [
        ".ibtn", ".nfc", ".shd", ".sub", ".rfid", ".ir",
        ".fmf", ".txt", "log", "fim"
    ]

    public enum Error: Swift.Error, Equatable {
        case directoryIsNotEmpty
        case unknown(String)
    }

    public init(storage: StorageAPI) {
        self.storage = storage
    }

    // MARK: Directory

    public func list(at path: Path) async throws -> [Element] {
        do {
            return try await storage.list(at: path)
        } catch {
            logger.error("list directory: \(error)")
            throw Error.unknown(.init(describing: error))
        }
    }

    // MARK: File

    public func canRead(_ file: File) -> Bool {
        supportedExtensions.contains {
            file.name.hasSuffix($0)
        }
    }

    public func readFile(at path: Path) async throws -> String {
        do {
            let bytes = try await storage.read(at: path).drain()
            return .init(decoding: bytes, as: UTF8.self)
        } catch {
            logger.error("read file: \(error)")
            throw Error.unknown(.init(describing: error))
        }
    }

    public func readRaw(at path: Path) async throws -> [UInt8] {
        do {
            return try await storage.read(at: path).drain()
        } catch {
            logger.error("read raw: \(error)")
            throw Error.unknown(.init(describing: error))
        }
    }

    public func writeFile(_ content: String, at path: Path) async throws {
        do {
            try await storage.write(at: path, string: content).drain()
        } catch {
            logger.error("write file: \(error)")
            throw Error.unknown(.init(describing: error))
        }
    }

    // MARK: Import

    public func importFile(url: URL, at path: Path) async throws {
        do {
            guard let name = url.pathComponents.last else {
                logger.error("import file: invalid url \(url)")
                return
            }
            guard url.startAccessingSecurityScopedResource() else {
                logger.error("import file: unable to access \(url)")
                return
            }
            defer {
                url.stopAccessingSecurityScopedResource()
            }

            let path = path.appending(name)
            let bytes = try [UInt8](Data(contentsOf: url))
            try await storage.write(at: path, bytes: bytes).drain()
        } catch {
            logger.error("import file: \(error)")
            throw Error.unknown(.init(describing: error))
        }
    }

    // Create

    public func create(
        path: Path,
        isDirectory: Bool
    ) async throws {
        do {
            try await storage.create(at: path, isDirectory: isDirectory)
        } catch {
            logger.error("create file: \(error)")
            throw Error.unknown(.init(describing: error))
        }
    }

    // Delete

    public func delete(
        _ element: Element,
        at path: Path,
        force: Bool = false
    ) async throws {
        do {
            let path = path.appending(element.name)
            try await storage.delete(at: path, force: force)
        } catch let error as Peripheral.Error
                    where error == .storage(.notEmpty) {
            throw Error.directoryIsNotEmpty
        } catch {
            logger.error("delete file: \(error)")
            throw Error.unknown(.init(describing: error))
        }
    }

    // Analytics

    func recordFileManager() {
        analytics.appOpen(target: .fileManager)
    }
}
