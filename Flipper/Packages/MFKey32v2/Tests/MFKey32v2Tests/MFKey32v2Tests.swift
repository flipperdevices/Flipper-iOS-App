import XCTest

@testable import MFKey32v2

class MFKey32v2Tests: XCTestCase {
    let data: ReaderData = .init(
        uid: 0x2a234f80,
        nt0: 0x55721809,
        nr0: 0xce9985f6,
        ar0: 0x772f55be,
        nt1: 0xa27173f2,
        nr1: 0xe386b505,
        ar1: 0x5fa65203)

    func testRecover() {
        XCTAssertEqual(recover(from: data), 176616078812325)
    }
}
