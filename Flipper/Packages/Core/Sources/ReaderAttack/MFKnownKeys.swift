import Inject
import Peripheral

public class MFKnownKeys {
    @Inject var rpc: RPC

    var flipperKeysPath: Path = "/ext/nfc/assets/mf_classic_dict.nfc"
    var userKeysPath: Path = "/ext/nfc/assets/mf_classic_dict_user.nfc"

    public init() {}

    private var flipperKeysExist: Bool {
        get async {
            (try? await rpc.getSize(at: flipperKeysPath)) != nil
        }
    }

    private var userKeysExist: Bool {
        get async {
            (try? await rpc.getSize(at: userKeysPath)) != nil
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
        await flipperKeysExist
            ? try await readKeys(at: flipperKeysPath)
            : []
    }

    public func readUserKeys() async throws -> Set<MFKey64> {
        await userKeysExist
            ? try await readKeys(at: userKeysPath)
            : []
    }

    public func readAllKeys() async throws -> Set<MFKey64> {
        try await readFlipperKeys().union(try await readUserKeys())
    }

    public func writeUserKeys(_ keys: Set<MFKey64>) async throws {
        try await writeKeys(keys, at: userKeysPath)
    }
}
