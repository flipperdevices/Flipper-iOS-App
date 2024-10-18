@testable import Core
import XCTest

class InfraredRemoteParserTest: XCTestCase {

    static let mockProperties = [
        // Meta Inforamtion
        ArchiveItem.Property(key: "Filetype", value: "IR signals file"),
        ArchiveItem.Property(key: "Version", value: "1"),

        // Parsed remote
        ArchiveItem.Property(key: "name", value: "Up"),
        ArchiveItem.Property(key: "type", value: "parsed"),
        ArchiveItem.Property(key: "protocol", value: "NECext"),
        ArchiveItem.Property(key: "address", value: "EE 87 00 00"),
        ArchiveItem.Property(key: "command", value: "0B A0 00 00"),

        // Raw remote
        ArchiveItem.Property(key: "name", value: "Right"),
        ArchiveItem.Property(key: "type", value: "raw"),
        ArchiveItem.Property(key: "frequency", value: "38000"),
        ArchiveItem.Property(key: "duty_cycle", value: "0.330000"),
        ArchiveItem.Property(key: "data", value: "3491 1722 433 435")
    ]

    static let mockRemotes = [
        ArchiveItem.InfraredSignal(
            name: "Up",
            hash: "",
            type: .parsed(.init(
                protocol: "NECext",
                address: "EE 87 00 00",
                command: "0B A0 00 00"))
        ),
        ArchiveItem.InfraredSignal(
            name: "Right",
            hash: "",
            type: .raw(.init(
                frequency: "38000",
                dutyCycle: "0.330000",
                data: "3491 1722 433 435"))
        )
    ]

    func testPropertiesToRemotes() {
        let item = ArchiveItem(
            name: "",
            kind: .infrared,
            properties: InfraredRemoteParserTest.mockProperties,
            shadowCopy: []
        )
        XCTAssertEqual(
            InfraredRemoteParserTest.mockRemotes,
            item.infraredSignals
        )
    }

    func testRemotesToProperties() {
        var item = ArchiveItem(
            name: "",
            kind: .infrared,
            properties: [],
            shadowCopy: []
        )
        item.infraredSignals = InfraredRemoteParserTest.mockRemotes
        XCTAssertEqual(
            item.properties,
            InfraredRemoteParserTest.mockProperties
        )
    }
}
