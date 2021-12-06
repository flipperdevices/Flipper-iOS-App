public class ArchiveStorageMock: ArchiveStorage {
    public var items: [ArchiveItem] = [
        .init(
            id: .init(.init(string: "/nfc/demo1")),
            name: .init(value: "Demo"),
            fileType: .nfc,
            properties: [.init(key: "key", value: "value")],
            isFavorite: true,
            status: .synchronizied),
        .init(
            id: .init(.init(string: "/ibutton/demo2")),
            name: .init(value: "Demo 2"),
            fileType: .ibutton,
            properties: [.init(key: "key", value: "value")],
            isFavorite: false,
            status: .synchronizied),
        .init(
            id: .init(.init(string: "/irda/demo3")),
            name: .init(value: "Demo 3"),
            fileType: .irda,
            properties: [.init(key: "key", value: "value")],
            isFavorite: false,
            status: .synchronizied),
        .init(
            id: .init(.init(string: "/rfid/demo4")),
            name: .init(value: "Demo 4"),
            fileType: .rfid,
            properties: [.init(key: "key", value: "value")],
            isFavorite: false,
            status: .synchronizied),
        .init(
            id: .init(.init(string: "/subghz/saved/demo5")),
            name: .init(value: "Demo 5"),
            fileType: .subghz,
            properties: [.init(key: "key", value: "value")],
            isFavorite: false,
            status: .synchronizied)
    ]
}
