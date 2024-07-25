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
        TextButtonData(
            keyId: .unknown,
            text: "Text Button")
    )

    static let mockIcon = InfraredButtonData.icon(
        IconButtonData(
            keyId: .unknown,
            icon: .power)
    )

    static let mockBase64Image = InfraredButtonData.base64Image(
        Base64ImageButtonData(
            keyId: .unknown,
            pngBase64: "image")
    )

    static let mockNavigation = InfraredButtonData.navigation(
        NavigationButtonData(
            upKeyId: .unknown,
            leftKeyId: .unknown,
            downKeyId: .unknown,
            rightKeyId: .unknown,
            okKeyId: .unknown
        )
    )

    static let mockVolume = InfraredButtonData.volume(
        VolumeButtonData(
            addKeyId: .unknown,
            reduceKeyId: .unknown)
    )

    static let mockChannel = InfraredButtonData.channel(
        ChannelButtonData(
            addKeyId: .unknown,
            reduceKeyId: .unknown)
    )

    static let mockUnknown = InfraredButtonData.unknown
}

fileprivate extension Data {
    static let mockTextButtonType =
    """
    {
        "text": "Text Button",
        "type": "TEXT"
    }
    """.data(using: .utf8)!

    static let mockIconButtonType =
    """
    {
        "type": "ICON",
        "icon_id": "POWER"
    }
    """.data(using: .utf8)!

    static let mockWrongIconButtonType =
    """
    {
        "key_id": {},
        "type": "ICON",
        "icon_id": "hakuna-matata"
    }
    """.data(using: .utf8)!

    static let mockBase64ButtonType =
    """
    {
        "key_id": {},
        "type": "BASE64_IMAGE",
        "png_base64": "image"
    }
    """.data(using: .utf8)!

    static let mockNavigationButtonType =
    """
    {
        "up_key_id": {},
        "left_key_id": {},
        "down_key_id": {},
        "right_key_id": {},
        "ok_key_id": {},
        "type": "NAVIGATION"
    }
    """.data(using: .utf8)!

    static let mockVolumeButtonType =
    """
    {
        "add_key_id": {},
        "reduce_key_id": {},
        "type": "VOLUME"
    }
    """.data(using: .utf8)!

    static let mockChannelButtonType =
    """
    {
        "add_key_id": {},
        "reduce_key_id": {},
        "type": "CHANNEL"
    }
    """.data(using: .utf8)!

    static let mockUknownType =
    """
    {
        "add_key_id": {},
        "reduce_key_id": {},
        "type": "hakuna-matata"
    }
    """.data(using: .utf8)!
}
