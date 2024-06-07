import Peripheral

import Foundation

class FlipperSystemAPI: SystemAPI {
    private var rpc: Session { pairedDevice.session }
    private let pairedDevice: PairedDevice

    init(pairedDevice: PairedDevice) {
        self.pairedDevice = pairedDevice
    }

    func deviceInfo() -> OldInfoStream {
        rpc.deviceInfo()
    }

    func powerInfo() -> OldInfoStream {
        rpc.powerInfo()
    }

    func property(_ key: String) -> ProperyStream {
        rpc.property(key)
    }

    @discardableResult
    func ping(_ bytes: [UInt8]) async throws -> [UInt8] {
        try await rpc.ping(bytes)
    }

    func reboot(to mode: OutgoingMessage.RebootMode) async throws {
        try await rpc.reboot(to: mode)
    }

    func getDate() async throws -> Date {
        try await rpc.getDate()
    }

    func setDate(_ date: Date) async throws {
        try await rpc.setDate(date)
    }

    func update(manifest: Path) async throws {
        try await rpc.update(manifest: manifest)
    }
}
