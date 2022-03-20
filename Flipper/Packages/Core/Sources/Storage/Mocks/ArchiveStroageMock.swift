public class ArchiveStorageMock: ArchiveStorage {
    public var items: [ArchiveItem] = [
        .init(
            name: .init("Demo"),
            fileType: .nfc,
            properties: [.init(key: "key", value: "value")]),
        .init(
            name: .init("Demo 2"),
            fileType: .ibutton,
            properties: [.init(key: "key", value: "value")]),
        .init(
            name: .init("Demo 3"),
            fileType: .infrared,
            properties: [.init(key: "key", value: "value")]),
        .init(
            name: .init("Demo 4"),
            fileType: .rfid,
            properties: [.init(key: "key", value: "value")]),
        .init(
            name: .init("Demo 5"),
            fileType: .subghz,
            properties: [.init(key: "key", value: "value")])
    ]
}
