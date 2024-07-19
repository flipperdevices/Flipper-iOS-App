import XCTest
@testable import Infrared

final class InfraredLayoutTest: BaseDecodableTestCase<InfraredLayout> {

    override func setUp() {
        super.setUp()
        testCases = [(.mock, .mock)]
    }
}

fileprivate extension InfraredLayout {
    static let mock = InfraredLayout(
        pages: [
            .init(buttons: [
                .init(
                    data: .icon(
                        .init(
                            keyId: KeyID.sha256(
                                SHA256KeyIDType(
                                    name: "power",
                                    hash: "hash")
                            ),
                            icon: .power
                        )
                    ),
                    position: .init(
                        y: 0,
                        x: 1,
                        alignment: .bottomLeft,
                        zIndex: 10,
                        containerWidth: 2,
                        containerHeight: 1,
                        contentWidth: 2,
                        contentHeight: 1
                    )
                ),
            ]),
        ]
    )
}


fileprivate extension Data {
    static let mock =
    """
    {
       "pages": [
          {
             "buttons": [
                {
                   "data": {
                      "key_id": {
                         "type": "SHA_256",
                         "key_name": "power",
                         "sha_256_string": "hash"
                      },
                      "icon_id": "POWER",
                      "type": "ICON"
                   },
                   "position":{
                      "y": 0,
                      "x": 1,
                      "alignment": "BOTTOM_LEFT",
                      "z_index": 10,
                      "container_width": 2,
                      "container_height": 1,
                      "content_width": 2,
                      "content_height": 1
                   }
                }
             ]
          }
       ]
    }
    """.data(using: .utf8)!
}
