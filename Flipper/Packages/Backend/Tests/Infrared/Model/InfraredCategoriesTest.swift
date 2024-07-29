import XCTest
@testable import Infrared

final class InfraredCategoriesTest: BaseDecodableTestCase<InfraredCategories> {

    override func setUp() {
        super.setUp()
        testCases = [(.mock, .mock)]
    }
}

fileprivate extension InfraredCategories {
    static let mock = InfraredCategories(
        categories: [
            .init(
                id: 1,
                meta: .init(
                    iconPngBase64: "png",
                    iconSVGBase64: "svg",
                    manifest: .init(
                        displayName: "A/V Receiver",
                        singularDisplayName: "A/V Singular Receiver"
                    )
                )
            )
        ]
    )
}

fileprivate extension Data {
    static let mock = Data(
        """
        {
            "categories": [
                {
                    "id": 1,
                    "meta": {
                        "icn_png_base64": "png",
                        "icn_svg_base64": "svg",
                        "manifest_content": {
                            "display_name": "A/V Receiver",
                            "singular_display_name": "A/V Singular Receiver"
                        }
                    }
                },
            ]
        }
        """.utf8
    )
}
