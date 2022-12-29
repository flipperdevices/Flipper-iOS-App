import DCompression

extension Array where Element == Update.Firmware.Entry {
    init(unpacking bytes: [UInt8]) async throws {
        let entries = try await TAR.decode(from: bytes, compression: .gzip)
        // directory + at least one file
        guard entries.count > 1, entries[0].typeflag == .directory else {
            throw Update.Error.invalidFirmware
        }
        self = entries.compactMap {
            switch $0.typeflag {
            case .file: return .file(.init(name: $0.name, data: $0.data))
            case .directory: return .directory($0.name)
            default: return nil
            }
        }
    }
}
