import XCTest
@testable import Infrared

final class InfraredKeyIDTest: BaseDecodableTestCase<KeyID> {

    override func setUp() {
        super.setUp()
        testCases = [
            (.mockName, .mockNameKeyID),
            (.mockSHA256, .mockSHA256KeyID),
            (.mockMD5, .mockMD5KeyID),
            (.mockUnknown, .mockUnknownKeyID)
        ]
    }
}

fileprivate extension KeyID {
    static let mockName = KeyID.name(
        NameKeyIDType(name: "mock")
    )

    static let mockSHA256 = KeyID.sha256(
        SHA256KeyIDType(name: "mock", hash: "sha256")
    )

    static let mockMD5 = KeyID.md5(
        MD5KeyIDType(name: "mock", hash: "md5")
    )

    static let mockUnknown = KeyID.unknown
}

fileprivate extension Data {
    static let mockNameKeyID =
    """
    {
        "type": "NAME",
        "key_name": "mock"
    }
    """.data(using: .utf8)!

    static let mockSHA256KeyID =
    """
    {
        "type": "SHA_256",
        "sha_256_string": "sha256",
        "key_name": "mock"
    }
    """.data(using: .utf8)!

    static let mockMD5KeyID =
    """
    {
        "type": "MD5",
        "md5_string": "md5",
        "key_name": "mock"
    }
    """.data(using: .utf8)!

    static let mockUnknownKeyID =
    """
    {
        "type": "hakuna-matata",
        "key_name": "mock"
    }
    """.data(using: .utf8)!
}
