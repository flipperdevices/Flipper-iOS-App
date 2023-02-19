import Analytics
import Peripheral

import Combine
import Foundation

@MainActor
public class RemoteFileManager: ObservableObject {
    // next step
    let pairedDevice: PairedDevice
    private var rpc: RPC { pairedDevice.session }

    private var supportedExtensions: [String] = [
        ".ibtn", ".nfc", ".shd", ".sub", ".rfid", ".ir", ".fmf", ".txt", "log"
    ]

    public enum Error: Swift.Error, Equatable {
        case directoryIsNotEmpty
        case unknown(String)
    }

    public init(pairedDevice: PairedDevice) {
        self.pairedDevice = pairedDevice
    }

    // MARK: Directory

    public func list(at path: Path) async throws -> [Element] {
        do {
            return try await rpc.listDirectory(at: path)
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
            let bytes = try await rpc.readFile(at: path)
            return .init(decoding: bytes, as: UTF8.self)
        } catch {
            logger.error("read file: \(error)")
            throw Error.unknown(.init(describing: error))
        }
    }

    public func writeFile(_ content: String, at path: Path) async throws {
        do {
            try await rpc.writeFile(at: path, string: content)
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
            try await rpc.writeFile(at: path, bytes: bytes)
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
            try await rpc.createFile(at: path, isDirectory: isDirectory)
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
            try await rpc.deleteFile(at: path, force: false)
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
