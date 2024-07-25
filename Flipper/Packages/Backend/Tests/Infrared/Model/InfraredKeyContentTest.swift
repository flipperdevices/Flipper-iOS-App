import XCTest
@testable import Infrared

final class InfraredKeyContentTest
: BaseDecodableTestCase<InfraredKeyContent> {

    override func setUp() {
        super.setUp()
        testCases = [(.mock, .mock)]
    }
}

fileprivate extension InfraredKeyContent {
    static let mock = InfraredKeyContent(
        content: "hakuna-matata"
    )
}

fileprivate extension Data {
    static let mock =
    """
    {
        "content": "hakuna-matata"
    }
    """.data(using: .utf8)!
}
