import Combine
import Injector

public class Archive: ObservableObject {
    public static let shared: Archive = .init()

    @Inject var storage: ArchiveStorage

    @Published public var isSynchronizing = false
    @Published public var items: [ArchiveItem] = [] {
        didSet {
            storage.items = items
        }
    }

    private let flipperArchive: FlipperArchive = .shared

    private init() {
        items = storage.items
        if items.isEmpty {
            items = demo
        }
    }

    public func append(_ item: ArchiveItem) {
        items.append(item)
    }

    public func delete(_ item: ArchiveItem) {
        items.removeAll { $0.id == item.id }
    }

    public func syncWithDevice(completion: @escaping () -> Void) {
        isSynchronizing = true
        flipperArchive.readFromDevice { items in
            self.isSynchronizing = false
            self.items = items
            completion()
        }
    }
}

var demo: [ArchiveItem] {
    [
        .init(
            id: "Office_guest_pass",
            name: "Office_guest_pass",
            description: "ID: 031,33351",
            isFavorite: true,
            kind: .rfid,
            origin: "EM-Marin"),
        .init(
            id: "Moms_bank_card",
            name: "Moms_bank_card",
            description: "ID: 031,33351",
            isFavorite: true,
            kind: .nfc,
            origin: "Mifare"),
        .init(
            id: "Open_garage_door",
            name: "Open_garage_door",
            description: "868,86 MHz",
            isFavorite: true,
            kind: .subghz,
            origin: "Doorhan"),
        .init(
            id: "Unknown_space_portal",
            name: "Unknown_space_portal",
            description: "ID: 03F4",
            isFavorite: true,
            kind: .ibutton,
            origin: "Cyfral"),
        .init(
            id: "Edifier_speaker",
            name: "Edifier_speaker",
            description: "",
            isFavorite: true,
            kind: .irda,
            origin: "")
    ]
}
