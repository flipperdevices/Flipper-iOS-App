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
    @Published var selectedItems: [ArchiveItem] = []
    @Published var isDeletePresented = false
    @Published var isEditing = false {
        didSet { onEditModeChanded(isEditing) }
    }
    var onEditModeChanded: (Bool) -> Void = { _ in }
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

    init(onEditModeChanded: @escaping (Bool) -> Void = { _ in }) {
        archive.items = demo

        self.onEditModeChanded = onEditModeChanded
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

    func openOptions() {
        toggleEditing()
    }

    func toggleEditing() {
        withAnimation {
            isEditing.toggle()
        }
        if isEditing {
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
