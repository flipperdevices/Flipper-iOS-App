public extension Task where Success == Never, Failure == Never {
    static func sleep(seconds: Int) async throws {
        try await Task.sleep(nanoseconds: UInt64(seconds) * 1000 * 1_000_000)
    }

    static func sleep(minutes: Int) async throws {
        try await sleep(seconds: minutes * 60)
    }
}
