import Peripheral

import Foundation

public protocol SystemAPI {
    typealias Property = Response.System.Property

    func deviceInfo() -> AsyncThrowingStream<(String, String), Swift.Error>
    func powerInfo() -> AsyncThrowingStream<(String, String), Swift.Error>
    func property(_ key: String) -> AsyncThrowingStream<Property, Swift.Error>
    @discardableResult
    func ping(_ bytes: [UInt8]) async throws -> [UInt8]
    func reboot(to mode: OutgoingMessage.RebootMode) async throws
    func getDate() async throws -> Date
    func setDate(_ date: Date) async throws
    func update(manifest: Path) async throws
}

extension SystemAPI {
    func deviceInfo() async throws -> [String: String] {
        var result: [String: String] = [:]
        for try await (key, value) in deviceInfo() {
            result[key] = value
        }
        return result
    }
}
