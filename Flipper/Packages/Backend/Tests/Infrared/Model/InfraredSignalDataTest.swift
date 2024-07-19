import XCTest
@testable import Infrared

final class InfraredSignalDataTest: BaseDecodableTestCase<InfraredSignalData> {

    override func setUp() {
        super.setUp()
        testCases = [
            (.mockRaw, .mockRaw),
            (.mockParsed, .mockParsed),
            (.mockUnknown, .mockUnknown),
        ]
    }
}

fileprivate extension InfraredSignalData {
    static let mockRaw = InfraredSignalData.raw(
        .init(frequency: "0", dutyCycle: "0", data: "0")
    )

    static let mockParsed = InfraredSignalData.parsed(
        .init(protocol: "0", address: "0", command: "0")
    )

    static let mockUnknown = InfraredSignalData.unknown
}


fileprivate extension Data {
    static let mockRaw =
    """
    {
        "frequency": "0",
        "duty_cycle": "0",
        "data": "0",
        "type": "raw"
    }
    """.data(using: .utf8)!

    static let mockParsed =
    """
    {
        "protocol": "0",
        "address": "0",
        "command": "0",
        "type": "parsed"
    }
    """.data(using: .utf8)!

    static let mockUnknown =
    """
    {
        "command": "0",
        "type": "hakuna-matata"
    }
    """.data(using: .utf8)!
}
