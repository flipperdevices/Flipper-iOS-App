import XCTest
@testable import Core

final class InfraredLayoutParserTests: XCTestCase {

    func testKitchenLayout() throws {
        let actualLayout = try JSONDecoder().decode(
            InfraredLayout.self,
            from: .mockKitchenLayout)

        XCTAssertEqual(actualLayout, InfraredLayout.mock)
    }
}
