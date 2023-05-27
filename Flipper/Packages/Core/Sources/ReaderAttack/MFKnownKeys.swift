import Peripheral

public class MFKnownKeys {
    private var pairedDevice: PairedDevice
    private var rpc: RPC { pairedDevice.session }

    init(pairedDevice: PairedDevice) {
        self.pairedDevice = pairedDevice
    }

    private var flipperKeysExist: Bool {
        get async throws {
            try await rpc.fileExists(at: .mfClassicDict)
        }
    }

    private var userKeysExist: Bool {
        get async throws {
            try await rpc.fileExists(at: .mfClassicDictUser)
        }
    }

    private func readKeys(at path: Path) async throws -> Set<MFKey64> {
        let bytes = try await rpc.readFile(at: path)
        let array = String(decoding: bytes, as: UTF8.self)
            .split { $0 == "\n" || $0 == "\r\n" }
            .compactMap { line in
                MFKey64(hexValue: line)
            }
        return .init(array)
    }

    private func writeKeys(_ keys: Set<MFKey64>, at path: Path) async throws {
        let string = keys
            .map(\.hexValue)
            .joined(separator: "\n")
        try await rpc.writeFile(at: path, string: string)
    }

    public func readFlipperKeys() async throws -> Set<MFKey64> {
        try await flipperKeysExist
            ? try await readKeys(at: .mfClassicDict)
            : []
    }

    public func readUserKeys() async throws -> Set<MFKey64> {
        try await userKeysExist
            ? try await readKeys(at: .mfClassicDictUser)
            : []
    }

    public func readAllKeys() async throws -> Set<MFKey64> {
        try await readFlipperKeys().union(try await readUserKeys())
    }

    public func writeUserKeys(_ keys: Set<MFKey64>) async throws {
        try await writeKeys(keys, at: .mfClassicDictUser)
    }
}
