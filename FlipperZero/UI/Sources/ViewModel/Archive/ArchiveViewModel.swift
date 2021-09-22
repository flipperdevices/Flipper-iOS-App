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
    @Published var selectedItems: [ArchiveItem] = []
    @Published var isEditing = false
    var disposeBag: DisposeBag = .init()

    init() {
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
                if let paired = self?.device {
                    // update the state for paired device
                    if let item = items.first(where: { $0.id == paired.id }) {
                        self?.device = item
                    }
                } else {
                    // new device connected
                    self?.device = items.first
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
