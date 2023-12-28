public extension Task where Success == Never, Failure == Never {
    static func sleep(milliseconds: Int) async throws {
        try await Task.sleep(nanoseconds: UInt64(milliseconds) * 1_000_000)
    }

    static func sleep(seconds: Int) async throws {
        try await Task.sleep(milliseconds: seconds * 1000)
    }

    static func sleep(minutes: Int) async throws {
        try await sleep(seconds: minutes * 60)
    }
}

public extension Task where Success == Never, Failure == Never {
    static func sleep(seconds: Double) async throws {
        try await Task.sleep(milliseconds: Int(seconds * 1000))
    }
}
