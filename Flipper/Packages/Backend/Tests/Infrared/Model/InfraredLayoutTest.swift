import XCTest
@testable import Infrared

final class InfraredDecodeLayoutTest: BaseDecodableTestCase<InfraredLayout> {

    override func setUp() {
        super.setUp()
        testCases = [(.mock, .mock)]
    }
}

final class InfraredEncodeLayoutTest: BaseEncodableTestCase<InfraredLayout> {

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
                            keyId: InfraredKeyID.sha256(
                                InfraredKeyID.SHA256(
                                    name: "power",
                                    hash: "hash")
                            ),
                            type: .power
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
                )
            ])
        ]
    )
}

fileprivate extension Data {
    static let mock = Data(
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
        """.utf8
    )
}
