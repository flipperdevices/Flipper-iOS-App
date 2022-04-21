import Inject
import Foundation

class RPCMock: RPC {
    func deviceInfo(
        priority: Priority?
    ) async throws -> [String: String] {
        .init()
    }

    @discardableResult
    func ping(
        _ bytes: [UInt8],
        priority: Priority?
    ) async throws -> [UInt8] {
        .init()
    }

    func reboot(
        to mode: Message.RebootMode,
        priority: Priority?
    ) async throws {
    }

    func getDate(priority: Priority?) async throws -> Date {
        .init()
    }

    func setDate(_ date: Date, priority: Priority?) async throws {
    }

    func getStorageInfo(
        at path: Path,
        priority: Priority?
    ) async throws -> StorageSpace {
        .init(free: 0, total: 0)
    }

    func listDirectory(
        at path: Path,
        priority: Priority?
    ) async throws -> [Element] {
        .init()
    }

    func createFile(
        at path: Path,
        isDirectory: Bool,
        priority: Priority?
    ) async throws {
    }

    func deleteFile(
        at path: Path,
        force: Bool,
        priority: Priority?
    ) async throws {
    }

    func readFile(
        at path: Path,
        priority: Priority? = nil
    ) async throws -> [UInt8] {
        .init()
    }

    func writeFile(
        at path: Path,
        bytes: [UInt8],
        priority: Priority?
    ) async throws {
    }

    func moveFile(
        from: Path,
        to: Path,
        priority: Priority?
    ) async throws {
    }

    func calculateFileHash(
        at path: Path,
        priority: Priority?
    ) async throws -> Hash {
        .init("")
    }

    func startStreaming(priority: Priority?) async throws {
    }

    func stopStreaming(priority: Priority?) async throws {
    }

    func onScreenFrame(_ body: @escaping (ScreenFrame) -> Void) {
    }

    func pressButton(
        _ button: InputKey,
        priority: Priority?
    ) async throws {
    }

    func playAlert(priority: Priority?) async throws {
    }

    func startVirtualDisplay(priority: Priority?) async throws {
    }

    func stopVirtualDisplay(priority: Priority?) async throws {
    }

    func sendScreenFrame(
        _ frame: ScreenFrame,
        priority: Priority?
    ) async throws {
    }
}
