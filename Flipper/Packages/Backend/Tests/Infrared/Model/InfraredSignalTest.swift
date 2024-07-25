import XCTest
@testable import Infrared

final class InfraredSignalTest: BaseDecodableTestCase<InfraredSignal> {

    override func setUp() {
        super.setUp()
        testCases = [(.mock, .mock)]
    }
}

fileprivate extension InfraredSignal {
    static let mock = InfraredSignal(
        response: .init(
            model: .init(
                id: 0,
                ifrFileId: 0,
                brandId: 0,
                categoryId: 0,
                name: "name",
//                fff: .unknown,
                hash: "hash"
            ),
            message: "message",
            categoryName: "categoryName",
            data: .unknown
        )
    )
}


fileprivate extension Data {
    static let mock =
    """
    {
        "signal_response": {
            "signal_model": {
                "id": 0,
                "ifr_file_id": 0,
                "brand_id": 0,
                "category_id": 0,
                "name": "name",
                "fff": {},
                "hash": "hash"
            },
            "message": "message",
            "category_name": "categoryName",
            "data": {
                "type": "hakuna-matata",
            }
        }
    }
    """.data(using: .utf8)!
}
