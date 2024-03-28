import SwiftUI
import XCTest
@testable import Core

class CachedTaskExecutorTest: XCTestCase {

    func testOneTimeCache() async throws {
        let key = "test"
        var called: [String] = .init()

        let executor = CachedTaskExecutor<String, Int> { key in
            called.append(key)
            return 1
        }

        let firstRequest = try await executor.get(key)
        XCTAssertEqual(firstRequest, 1)

        let secondRequest = try await executor.get(key)
        XCTAssertEqual(secondRequest, 1)

        XCTAssertEqual(called, [key])
    }

    func testRaceConditionCache() async throws {
        let key = "test"
        var called: [String] = .init()

        let executor = CachedTaskExecutor<String, Void> { key in
            called.append(key)
            try await Task.sleep(for: .milliseconds(1))
        }

        try await withThrowingTaskGroup(of: Void.self) { group in
            for _ in 0..<10 {
                group.addTask { try await executor.get(key) }
            }
            try await group.waitForAll()
        }

        XCTAssertEqual(called, [key])
    }
}
