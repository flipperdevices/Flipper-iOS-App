import Peripheral

import Foundation

public protocol SystemAPI {
    typealias OldInfoStream = AsyncThrowingStream<(String, String), Swift.Error>
    typealias ProperyStream = AsyncThrowingStream<Property, Swift.Error>
    typealias Property = Response.System.Property

    func deviceInfo() async -> OldInfoStream
    func powerInfo() async -> OldInfoStream
    func property(_ key: String) async -> ProperyStream
    @discardableResult
    func ping(_ bytes: [UInt8]) async throws -> [UInt8]
    func reboot(to mode: OutgoingMessage.RebootMode) async throws
    func getDate() async throws -> Date
    func setDate(_ date: Date) async throws
    func update(manifest: Path) async throws
}

extension SystemAPI.OldInfoStream {
    func drain() async throws -> [String: String] {
        var result: [String: String] = [:]
        for try await (key, value) in self {
            result[key] = value
        }
        return result
    }
}

extension SystemAPI.ProperyStream {
    func drain() async throws -> [String: String] {
        var result: [String: String] = [:]
        for try await property in self {
            result[property.key] = property.value
        }
        return result
    }
}
