import Foundation

public protocol RPC {
    var session: Session? { get }

    // MARK: System

    func deviceInfo() async throws -> [String: String]
    @discardableResult
    func ping(_ bytes: [UInt8]) async throws -> [UInt8]
    func reboot(to mode: Message.RebootMode) async throws
    func getDate() async throws -> Date
    func setDate(_ date: Date) async throws
    func update(manifest: Path) async throws

    // MARK: Storage

    func getStorageInfo(at path: Path) async throws -> StorageSpace
    func listDirectory(at path: Path) async throws -> [Element]
    func createFile(at path: Path, isDirectory: Bool) async throws
    func deleteFile(at path: Path, force: Bool) async throws
    func readFile(at path: Path) -> AsyncThrowingStream<[UInt8], Swift.Error>
    func writeFile(at path: Path, bytes: [UInt8]) -> AsyncThrowingStream<Int, Swift.Error>
    func moveFile(from: Path, to: Path) async throws
    func calculateFileHash(at path: Path) async throws -> Hash

    // MARK: Application

    func startRequest(_ name: String, args: String) async throws

    // MARK: GUI

    func startStreaming() async throws
    func stopStreaming() async throws
    func onScreenFrame(_ body: @escaping (ScreenFrame) -> Void)
    func pressButton(_ button: InputKey) async throws
    func playAlert() async throws
    func startVirtualDisplay(with frame: ScreenFrame?) async throws
    func stopVirtualDisplay() async throws
    func sendScreenFrame(_ frame: ScreenFrame) async throws
}

public extension RPC {
    func readFile(at path: Path) async throws -> [UInt8] {
        var result: [UInt8] = []
        for try await next in readFile(at: path) {
            result += next
        }
        return result
    }

    func writeFile(at path: Path, bytes: [UInt8]) async throws {
        for try await _ in writeFile(at: path, bytes: bytes) { }
    }

    func writeFile(at path: Path, string: String) async throws {
        try await writeFile(at: path, bytes: .init(string.utf8))
    }

    func deleteFile(at path: Path) async throws {
        try await deleteFile(at: path, force: false)
    }

    func createDirectory(at path: Path) async throws {
        try await createFile(at: path, isDirectory: true)
    }
}
