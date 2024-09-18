import XCTest

@testable import Core
@testable import Peripheral

class ArchiveSyncLayoutTests: XCTestCase {
    func testInfraredLayout() {
        let originPath = Path(
            components: [
                "ext",
                "infrared",
                "test.ir"
            ]
        )
        let expectedLayoutPath = Path(
            components: [
                "ext",
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
                "ext",
                "nfc",
                "test.nfc"
            ]
        )
        XCTAssertNil(originPath.layoutPath)
    }
}
