import XCTest
@testable import Infrared

final class InfraredKeyIDTest: BaseDecodableTestCase<InfraredKeyID> {

    override func setUp() {
        super.setUp()
        testCases = [
            (.mockName, .mockNameKeyID),
            (.mockSHA256, .mockSHA256KeyID),
            (.mockUnknown, .mockUnknownKeyID)
        ]
    }
}

fileprivate extension InfraredKeyID {
    static let mockName = InfraredKeyID.name(
        Name(name: "mock")
    )

    static let mockSHA256 = InfraredKeyID.sha256(
        SHA256(name: "mock", hash: "sha256")
    )

    static let mockUnknown = InfraredKeyID.unknown
}

fileprivate extension Data {
    static let mockNameKeyID = Data(
        """
        {
            "type": "NAME",
            "key_name": "mock"
        }
        """.utf8
    )

    static let mockSHA256KeyID = Data(
        """
        {
            "type": "SHA_256",
            "sha_256_string": "sha256",
            "key_name": "mock"
        }
        """.utf8
    )

    static let mockMD5KeyID = Data(
        """
        {
            "type": "MD5",
            "md5_string": "md5",
            "key_name": "mock"
        }
        """.utf8
    )

    static let mockUnknownKeyID = Data(
        """
        {
            "type": "hakuna-matata",
            "key_name": "mock"
        }
        """.utf8
    )
}
