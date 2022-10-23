import XCTest

@testable import Core

class ReaderAttackTests: XCTestCase {
    var log: String {
        "Sec 2 key A cuid 2a234f80 " +
        "nt0 55721809 nr0 ce9985f6 ar0 772f55be " +
        "nt1 a27173f2 nr1 e386b505 ar1 5fa65203"
    }

    func testAttack() async throws {
        let stream = ReaderAttack.recoverKeys(from: try .init(log))
        guard let result = await stream.first(where: { _ in true }) else {
            XCTFail("No keys found")
            return
        }
        XCTAssertEqual(result.key, 176616078812325)
    }
}
