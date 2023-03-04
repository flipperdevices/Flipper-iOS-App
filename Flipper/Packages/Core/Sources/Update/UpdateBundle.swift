import DCompression

// TODO: Rename to Directory

public struct UpdateBundle {
    let entries: [Entry]

    public enum Entry {
        case file(File)
        case directory(String)
    }

    public struct File {
        let name: String
        let data: [UInt8]
    }

    var files: [File] {
        entries.compactMap { entry in
            switch entry {
            case let .file(file): return file
            default: return nil
            }
        }
    }
}

// MARK: Decoding

extension UpdateBundle {
    init(unpacking bytes: [UInt8]) async throws {
        let entries = try await TAR.decode(from: bytes, compression: .gzip)
        // directory + at least one file
        guard entries.count > 1, entries[0].typeflag == .directory else {
            throw Update.Error.invalidFirmware
        }
        self.entries = entries.compactMap {
            switch $0.typeflag {
            case .file: return .file(.init(name: $0.name, data: $0.data))
            case .directory: return .directory($0.name)
            default: return nil
            }
        }
    }
}
