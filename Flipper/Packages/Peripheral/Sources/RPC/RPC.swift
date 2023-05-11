import Foundation

public protocol RPC: AnyObject {
    // TODO: Use async sequence
    var onScreenFrame: ((ScreenFrame) -> Void)? { get set }
    var onAppStateChanged: ((Message.AppState) -> Void)? { get set }

    // MARK: System

    func deviceInfo() -> AsyncThrowingStream<(String, String), Swift.Error>
    func powerInfo() -> AsyncThrowingStream<(String, String), Swift.Error>
    func property(_ key: String) -> AsyncThrowingStream<Response.System.Property, Swift.Error>
    @discardableResult
    func ping(_ bytes: [UInt8]) async throws -> [UInt8]
    func reboot(to mode: Message.RebootMode) async throws
    func getDate() async throws -> Date
    func setDate(_ date: Date) async throws
    func update(manifest: Path) async throws

    // MARK: Storage

    func getStorageInfo(at path: Path) async throws -> StorageSpace
    func listDirectory(at path: Path) async throws -> [Element]
    func getSize(at path: Path) async throws -> Int
    func getTimestamp(at path: Path) async throws -> Date
    func createFile(at path: Path, isDirectory: Bool) async throws
    func deleteFile(at path: Path, force: Bool) async throws
    func readFile(at path: Path) -> AsyncThrowingStream<[UInt8], Swift.Error>
    func writeFile(at path: Path, bytes: [UInt8]) -> AsyncThrowingStream<Int, Swift.Error>
    func moveFile(from: Path, to: Path) async throws
    func calculateFileHash(at path: Path) async throws -> Hash

    // MARK: Application

    var isApplicationLocked: Bool { get async throws }

    func appStart(_ name: String, args: String) async throws
    func appLoadFile(_ path: Path) async throws
    func appButtonPress(_ button: String) async throws
    func appButtonRelease() async throws
    func appExit() async throws

    // MARK: Desktop

    var isDesktopLocked: Bool { get async throws }

    func unlock() async throws

    // MARK: GUI

    func startStreaming() async throws
    func stopStreaming() async throws
    func pressButton(_ button: InputKey) async throws
    func playAlert() async throws
    func startVirtualDisplay(with frame: ScreenFrame?) async throws
    func stopVirtualDisplay() async throws
    func sendScreenFrame(_ frame: ScreenFrame) async throws
}

public extension RPC {
    func deviceInfo() async throws -> [String: String] {
        var result: [String: String] = [:]
        for try await (key, value) in deviceInfo() {
            result[key] = value
        }
        return result
    }

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

    func appButtonPress() async throws {
        try await appButtonPress("")
    }
}

public extension RPC {
    func fileExists(at path: Path) async throws -> Bool {
        do {
            _ = try await getSize(at: path)
            return true
        } catch let error as Error where error == .storage(.doesNotExist) {
            return false
        }
    }

    func readFile(
        at path: Path,
        progress: (Double) -> Void
    ) async throws -> String {
        let size = try await getSize(at: path)
        guard size > 0 else {
            progress(1)
            return ""
        }
        var bytes: [UInt8] = []
        for try await next in readFile(at: path) {
            bytes += next
            progress(Double(bytes.count) / Double(size))
        }
        return .init(decoding: bytes, as: UTF8.self)
    }

    func writeFile(
        at path: Path,
        string: String,
        progress: (Double) -> Void
    ) async throws {
        let bytes = [UInt8](string.utf8)
        guard !bytes.isEmpty else {
            progress(1)
            return
        }
        var sent = 0
        for try await next in writeFile(at: path, bytes: bytes) {
            sent += next
            progress(Double(sent) / Double(bytes.count))
        }
    }
}
