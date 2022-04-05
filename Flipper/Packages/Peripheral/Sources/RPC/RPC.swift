import Foundation

public protocol RPC {

    // MARK: System

    func deviceInfo(
        priority: Priority?
    ) async throws -> [String: String]

    @discardableResult
    func ping(
        _ bytes: [UInt8],
        priority: Priority?
    ) async throws -> [UInt8]

    func reboot(
        to mode: Request.System.RebootMode,
        priority: Priority?
    ) async throws

    func getDate(
        priority: Priority?
    ) async throws -> Date

    func setDate(
        _ date: Date,
        priority: Priority?
    ) async throws

    // MARK: Storage

    func getStorageInfo(
        at path: Path,
        priority: Priority?
    ) async throws -> StorageSpace

    func listDirectory(
        at path: Path,
        priority: Priority?
    ) async throws -> [Element]

    func createFile(
        at path: Path,
        isDirectory: Bool,
        priority: Priority?
    ) async throws

    func deleteFile(
        at path: Path,
        force: Bool,
        priority: Priority?
    ) async throws

    func readFile(
        at path: Path,
        priority: Priority?
    ) async throws -> [UInt8]

    func writeFile(
        at path: Path,
        bytes: [UInt8],
        priority: Priority?
    ) async throws

    func moveFile(
        from: Path,
        to: Path,
        priority: Priority?
    ) async throws

    func calculateFileHash(
        at path: Path,
        priority: Priority?
    ) async throws -> Hash

    // MARK: GUI

    func startStreaming(
        priority: Priority?
    ) async throws

    func stopStreaming(
        priority: Priority?
    ) async throws

    func onScreenFrame(
        _ body: @escaping (ScreenFrame) -> Void
    )

    func pressButton(
        _ button: InputKey,
        priority: Priority?
    ) async throws

    func playAlert(
        priority: Priority?
    ) async throws

    func startVirtualDisplay(
        priority: Priority?
    ) async throws

    func stopVirtualDisplay(
        priority: Priority?
    ) async throws

    func sendScreenFrame(
        _ frame: ScreenFrame,
        priority: Priority?
    ) async throws
}

public extension RPC {
    func writeFile(
        at path: Path,
        string: String,
        priority: Priority? = nil
    ) async throws {
        try await writeFile(
            at: path,
            bytes: .init(string.utf8),
            priority: priority)
    }
}

// MARK: Default priority

public extension RPC {

    // MARK: System

    func deviceInfo() async throws -> [String: String] {
        try await deviceInfo(priority: nil)
    }

    @discardableResult
    func ping(_ bytes: [UInt8]) async throws -> [UInt8] {
        try await ping(bytes, priority: nil)
    }

    func reboot(to mode: Request.System.RebootMode) async throws {
        try await reboot(to: mode, priority: nil)
    }

    func getDate() async throws -> Date {
        try await getDate(priority: nil)
    }

    func setDate(_ date: Date) async throws {
        try await setDate(date, priority: nil)
    }

    // MARK: Storage

    func getStorageInfo(at path: Path) async throws -> StorageSpace {
        try await getStorageInfo(at: path, priority: nil)
    }

    func listDirectory(at path: Path) async throws -> [Element] {
        try await listDirectory(at: path, priority: nil)
    }

    func createFile(at path: Path, isDirectory: Bool) async throws {
        try await createFile(at: path, isDirectory: isDirectory, priority: nil)
    }

    func deleteFile(at path: Path) async throws {
        try await deleteFile(at: path, force: false, priority: nil)
    }

    func deleteFile(at path: Path, force: Bool) async throws {
        try await deleteFile(at: path, force: force, priority: nil)
    }

    func readFile(at path: Path) async throws -> [UInt8] {
        try await readFile(at: path, priority: nil)
    }

    func writeFile(at path: Path, bytes: [UInt8]) async throws {
        try await writeFile(at: path, bytes: bytes, priority: nil)
    }

    func moveFile(from: Path, to: Path) async throws {
        try await moveFile(from: from, to: to, priority: nil)
    }

    func calculateFileHash(at path: Path) async throws -> Hash {
        try await calculateFileHash(at: path, priority: nil)
    }

    // MARK: GUI

    func startStreaming() async throws {
        try await startStreaming(priority: nil)
    }

    func stopStreaming() async throws {
        try await stopStreaming(priority: nil)
    }

    func pressButton(_ button: InputKey) async throws {
        try await pressButton(button, priority: nil)
    }

    func playAlert() async throws {
        try await playAlert(priority: nil)
    }

    func startVirtualDisplay() async throws {
        try await startVirtualDisplay(priority: nil)
    }

    func stopVirtualDisplay() async throws {
        try await stopVirtualDisplay(priority: nil)
    }

    func sendScreenFrame(_ frame: ScreenFrame) async throws {
        try await sendScreenFrame(frame, priority: nil)
    }
}
