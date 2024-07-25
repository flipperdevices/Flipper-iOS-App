import XCTest
@testable import Infrared

final class InfraredBrandsTest: BaseDecodableTestCase<InfraredBrands> {

    override func setUp() {
        super.setUp()
        testCases = [(.mock, .mock)]
    }
}

fileprivate extension InfraredBrands {
    static let mock = InfraredBrands(brands: [
        InfraredBrand(id: 1, name: "one"),
        InfraredBrand(id: 2, name: "two")
    ])
}

fileprivate extension Data {
    static let mock =
    """
    {
        "brands": [
            {
                "id": 1,
                "name": "one",
                "category_id": 1
            },
            {
                "id": 2,
                "name": "two",
                "category_id": 1
            }
        ]
    }
    """.data(using: .utf8)!
}
