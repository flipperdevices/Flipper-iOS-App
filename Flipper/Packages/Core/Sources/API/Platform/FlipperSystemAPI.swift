import Peripheral

import Foundation

class FlipperSystemAPI: SystemAPI {
    private var rpc: Session { pairedDevice.session }
    private let pairedDevice: PairedDevice

    init(pairedDevice: PairedDevice) {
        self.pairedDevice = pairedDevice
    }

    func deviceInfo() -> AsyncThrowingStream<(String, String), Swift.Error> {
        rpc.deviceInfo()
    }

    func powerInfo() -> AsyncThrowingStream<(String, String), Swift.Error> {
        rpc.powerInfo()
    }

    func property(_ key: String) -> AsyncThrowingStream<Property, Swift.Error> {
        rpc.property(key)
    }

    @discardableResult
    func ping(_ bytes: [UInt8]) async throws -> [UInt8] {
        try await rpc.ping(bytes)
    }

    func reboot(to mode: Message.RebootMode) async throws {
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
