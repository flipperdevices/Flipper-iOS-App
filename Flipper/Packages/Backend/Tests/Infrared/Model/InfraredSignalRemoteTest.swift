import XCTest
@testable import Infrared

final class InfraredSignalDataTest: BaseDecodableTestCase<InfraredSignalRemote>
{
    override func setUp() {
        super.setUp()
        testCases = [
            (.mockRaw, .mockRaw),
            (.mockParsed, .mockParsed)]
    }
}

fileprivate extension InfraredSignalRemote {
    static let mockRaw = InfraredSignalRemote.raw(
        .init(frequency: "0", dutyCycle: "0", data: "0", name: "name")
    )

    static let mockParsed = InfraredSignalRemote.parsed(
        .init(protocol: "0", address: "0", command: "0", name: "name")
    )
}

fileprivate extension Data {
    static let mockRaw = Data(
        """
        {
            "frequency": "0",
            "duty_cycle": "0",
            "data": "0",
            "type": "raw",
            "name": "name"
        }
        """.utf8
    )

    static let mockParsed = Data(
        """
        {
            "protocol": "0",
            "address": "0",
            "command": "0",
            "type": "parsed",
            "name": "name"
        }
        """.utf8
    )
}
