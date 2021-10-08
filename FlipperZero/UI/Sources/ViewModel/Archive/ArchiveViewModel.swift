import Core
import Combine
import Injector
import SwiftUI

class ArchiveViewModel: ObservableObject {
    @Inject var nfc: NFCServiceProtocol
    @Inject var archive: ArchiveStorage
    @Inject var storage: DeviceStorage
    @Inject var connector: BluetoothConnector

    @Published var device: Peripheral?
    @Published var items: [ArchiveItem] = [] {
        didSet {
            archive.items = items
        }
    }
    @Published var selectedCategoryIndex = 0
    @Published var isDeletePresented = false
    @Published var selectedItems: [ArchiveItem] = []
    @Published var isSelectItemsMode = false {
        didSet { onSelectItemsModeChanded(isSelectItemsMode) }
    }
    var onSelectItemsModeChanded: (Bool) -> Void = { _ in }
    var disposeBag: DisposeBag = .init()

    var categories: [String] = [
        "Favorites", "RFID 125", "Sub-gHz", "NFC", "iButton", "iRda"
    ]

    struct Group: Identifiable {
        var id: ArchiveItem.Kind?
        var items: [ArchiveItem]
    }

    var itemGroups: [Group] {
        var groups: [Group] = [.init(id: nil, items: items)]
        ArchiveItem.Kind.allCases.forEach { kind in
            groups.append(.init(
                id: kind,
                items: items.filter { $0.kind == kind }))
        }
        return groups
    }

    init(onSelectItemsModeChanded: @escaping (Bool) -> Void = { _ in }) {
        archive.items = demo

        self.onSelectItemsModeChanded = onSelectItemsModeChanded
        device = storage.pairedDevice
        items = archive.items

        nfc.items
            .sink { [weak self] newItems in
                guard let self = self else { return }
                if let item = newItems.first, !self.items.contains(item) {
                    self.items.append(item)
                }
            }
            .store(in: &disposeBag)

        connector.connectedPeripherals
            .sink { [weak self] items in
                if let item = items.first {
                    self?.device = .init(item)
                }
            }
            .store(in: &disposeBag)
    }

    func toggleSelectItems() {
        withAnimation {
            isSelectItemsMode.toggle()
        }
        if isSelectItemsMode {
            selectedItems.removeAll()
        }
    }

    func selectItem(_ item: ArchiveItem) {
        if let index = selectedItems.firstIndex(of: item) {
            selectedItems.remove(at: index)
        } else {
            selectedItems.append(item)
        }
    }

    enum SortOption {
        case creationDate
        case title
        case oldestFirst
        case newestFirst
    }

    func sortItems(by option: SortOption) {
        items.sort {
            switch option {
            case .creationDate: return $0.name < $1.name
            case .title: return $0.description < $1.description
            case .oldestFirst: return $0.kind < $1.kind
            case .newestFirst: return $0.origin < $1.origin
            }
        }
    }

    func readNFCTag() {
        nfc.startReader()
    }

    func onCardSwipe(_ width: Double) {
        switch width {
        case 10...:
            if selectedCategoryIndex > 0 {
                selectedCategoryIndex -= 1
            }
        case ...(-10):
            if selectedCategoryIndex < items.count {
                selectedCategoryIndex += 1
            }
        default:
            break
        }
    }

    func shareSelectedItems() {
        if !selectedItems.isEmpty {
            share(selectedItems.map { $0.name })
        }
    }

    func deleteSelectedItems() {
        if !selectedItems.isEmpty {
            isDeletePresented = true
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
            wut: "EM-Marin"),
        .init(
            id: "Moms_bank_card",
            name: "Moms_bank_card",
            description: "ID: 031,33351",
            isFavorite: true,
            kind: .nfc,
            wut: "Mifare"),
        .init(
            id: "Open_garage_door",
            name: "Open_garage_door",
            description: "868,86 MHz",
            isFavorite: true,
            kind: .subghz,
            wut: "Doorhan"),
        .init(
            id: "Unknown_space_portal",
            name: "Unknown_space_portal",
            description: "ID: 03F4",
            isFavorite: true,
            kind: .ibutton,
            wut: "Cyfral"),
        .init(
            id: "Edifier_speaker",
            name: "Edifier_speaker",
            description: "",
            isFavorite: true,
            kind: .irda,
            wut: "")
    ]
}
