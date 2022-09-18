import Inject
import Foundation

class RPCMock: RPC {
    var session: Session?

    func deviceInfo() -> AsyncThrowingStream<(String, String), Swift.Error> {
        .init { _ in }
    }

    func powerInfo() -> AsyncThrowingStream<(String, String), Swift.Error> {
        .init { _ in }
    }

    @discardableResult
    func ping(_ bytes: [UInt8]) async throws -> [UInt8] {
        .init()
    }

    func reboot(to mode: Message.RebootMode) async throws {
    }

    func getDate() async throws -> Date {
        .init()
    }

    func setDate(_ date: Date) async throws {
    }

    func update(manifest: Path) async throws {
    }

    func getStorageInfo(at path: Path) async throws -> StorageSpace {
        .init(free: 0, total: 0)
    }

    func listDirectory(at path: Path) async throws -> [Element] {
        .init()
    }

    func getSize(at path: Path) async throws -> Int {
        0
    }

    func createFile(at path: Path, isDirectory: Bool) async throws {
    }

    func deleteFile(at path: Path, force: Bool) async throws {
    }

    func readFile(at path: Path) -> AsyncThrowingStream<[UInt8], Swift.Error> {
        .init { _ in }
    }

    func writeFile(at path: Path, bytes: [UInt8]) -> AsyncThrowingStream<Int, Swift.Error> {
        .init { _ in }
    }

    func moveFile(from: Path, to: Path) async throws {
    }

    func calculateFileHash(at path: Path) async throws -> Hash {
        .init("")
    }

    func appStart(_ name: String, args: String) async throws {
    }

    func appLoadFile(_ path: Path) async throws {
    }

    func appButtonPress(_ button: String) async throws {
    }

    func appButtonRelease() async throws {
    }

    func appExit() async throws {
    }

    func startStreaming() async throws {
    }

    func stopStreaming() async throws {
    }

    func onScreenFrame(_ body: @escaping (ScreenFrame) -> Void) {
    }

    func onAppStateChanged(_ body: @escaping (Message.AppState) -> Void) {
    }

    func pressButton(_ button: InputKey) async throws {
    }

    func playAlert() async throws {
    }

    func startVirtualDisplay(with frame: ScreenFrame?) async throws {
    }

    func stopVirtualDisplay() async throws {
    }

    func sendScreenFrame(_ frame: ScreenFrame) async throws {
    }
}
