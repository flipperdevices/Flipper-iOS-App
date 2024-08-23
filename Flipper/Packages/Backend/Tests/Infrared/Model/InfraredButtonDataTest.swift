import XCTest
@testable import Infrared

final class InfraredButtonDataTest: BaseDecodableTestCase<InfraredButtonData> {

    override func setUp() {
        super.setUp()
        testCases = [
            (.mockText, .mockTextButtonType),
            (.mockIcon, .mockIconButtonType),
            (.mockBase64Image, .mockBase64ButtonType),
            (.mockNavigation, .mockNavigationButtonType),
            (.mockVolume, .mockVolumeButtonType),
            (.mockChannel, .mockChannelButtonType),
            (.mockUnknown, .mockUknownType)
        ]
    }

    func testWrongIconType() throws {
        XCTAssertThrowsError(
            try JSONDecoder().decode(
                DecodableStruct.self,
                from: .mockWrongIconButtonType)
        )
    }
}

fileprivate extension InfraredButtonData {
    static let mockText = InfraredButtonData.text(
        Text(
            keyId: .unknown,
            text: "Text Button")
    )

    static let mockIcon = InfraredButtonData.icon(
        Icon(
            keyId: .unknown,
            type: .power)
    )

    static let mockBase64Image = InfraredButtonData.base64Image(
        Base64Image(
            keyId: .unknown,
            pngBase64: "image")
    )

    static let mockNavigation = InfraredButtonData.navigation(
        Navigation(
            upKeyId: .unknown,
            leftKeyId: .unknown,
            downKeyId: .unknown,
            rightKeyId: .unknown,
            okKeyId: .unknown
        )
    )

    static let mockVolume = InfraredButtonData.volume(
        Volume(
            addKeyId: .unknown,
            reduceKeyId: .unknown)
    )

    static let mockChannel = InfraredButtonData.channel(
        Channel(
            addKeyId: .unknown,
            reduceKeyId: .unknown)
    )

    static let mockUnknown = InfraredButtonData.unknown
}

fileprivate extension Data {
    static let mockTextButtonType = Data(
        """
        {
            "text": "Text Button",
            "type": "TEXT"
        }
        """.utf8
    )

    static let mockIconButtonType = Data(
        """
        {
            "type": "ICON",
            "icon_id": "POWER"
        }
        """.utf8
    )

    static let mockWrongIconButtonType = Data(
        """
        {
            "key_id": {},
            "type": "ICON",
            "icon_id": "hakuna-matata"
        }
        """.utf8
    )

    static let mockBase64ButtonType = Data(
        """
        {
            "key_id": {},
            "type": "BASE64_IMAGE",
            "png_base64": "image"
        }
        """.utf8
    )

    static let mockNavigationButtonType = Data(
        """
        {
            "up_key_id": {},
            "left_key_id": {},
            "down_key_id": {},
            "right_key_id": {},
            "ok_key_id": {},
            "type": "NAVIGATION"
        }
        """.utf8
    )

    static let mockVolumeButtonType = Data(
        """
        {
            "add_key_id": {},
            "reduce_key_id": {},
            "type": "VOLUME"
        }
        """.utf8
    )

    static let mockChannelButtonType = Data(
        """
        {
            "add_key_id": {},
            "reduce_key_id": {},
            "type": "CHANNEL"
        }
        """.utf8
    )

    static let mockUknownType = Data(
        """
        {
            "add_key_id": {},
            "reduce_key_id": {},
            "type": "hakuna-matata"
        }
        """.utf8
    )
}
