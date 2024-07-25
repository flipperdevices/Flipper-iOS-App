import XCTest
@testable import Infrared

final class InfraredButtonTest: BaseDecodableTestCase<InfraredButton> {

    override func setUp() {
        super.setUp()
        testCases = [(.mock, .mock)]
    }
}

fileprivate extension InfraredButton {
    static let mock = InfraredButton(
        data: .unknown,
        position: .init(y: 0, x: 0)
    )
}

fileprivate extension Data {
    static let mock =
    """
    {
        "data": {
            "type": "hakuna-matata"
        },
        "position": {
            "y": 0,
            "x": 0
        }
    }
    """.data(using: .utf8)!
}
