import XCTest
@testable import Infrared

final class InfraredButtonPositionTest
: BaseDecodableTestCase<InfraredButtonPosition> {

    override func setUp() {
        super.setUp()
        testCases = [
            (.mockAllField, .mockAllField),
            (.mockEmptyFields, .mockEmptyFields)
        ]
    }

    func testWrongAligment() throws {
        XCTAssertThrowsError(
            try JSONDecoder().decode(
                DecodableStruct.self,
                from: .mockWrongAlignment)
        )
    }
}

fileprivate extension InfraredButtonPosition {
    static let mockAllField = InfraredButtonPosition(
        y: 0,
        x: 1,
        alignment: .bottomLeft,
        zIndex: 10,
        containerWidth: 2,
        containerHeight: 1,
        contentWidth: 2,
        contentHeight: 1
    )

    static let mockEmptyFields = InfraredButtonPosition(
        y: 0,
        x: 1
    )
}

fileprivate extension Data {
    static let mockAllField = Data(
        """
        {
            "y": 0,
            "x": 1,
            "alignment": "BOTTOM_LEFT",
            "z_index": 10,
            "container_width": 2,
            "container_height": 1,
            "content_width": 2,
            "content_height": 1
        }
        """.utf8
    )

    static let mockEmptyFields = Data(
        """
        {
            "y": 0,
            "x": 1
        }
        """.utf8
    )

    static let mockWrongAlignment = Data(
        """
        {
            "y": 0,
            "x": 1,
            "alignment": "hakuna-matata"
        }
        """.utf8
    )
}
