import XCTest

@testable import Core
@testable import Peripheral

class ArchiveSyncLayoutTests: XCTestCase {
    func testInfraredLayout() {
        let originPath = Path(
            components: [
                "any",
                "infrared",
                "test.ir"
            ]
        )
        let expectedLayoutPath = Path(
            components: [
                "any",
                "infrared",
                "test.irui"
            ]
        )
        let actualLayoutPath = originPath.layoutPath

        XCTAssertEqual(expectedLayoutPath, actualLayoutPath)
    }

    func testUnsupportedLayout() {
        let originPath = Path(
            components: [
                "any",
                "nfc",
                "test.nfc"
            ]
        )
        XCTAssertNil(originPath.layoutPath)
    }
}
