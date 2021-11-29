import Core
import Combine
import Injector
import SwiftUI

@MainActor
class ArchiveViewModel: ObservableObject {
    @Inject var nfc: NFCServiceProtocol
    @Inject var storage: DeviceStorage
    @Inject var pairedDevice: PairedDevice
    var disposeBag: DisposeBag = .init()

    @Published var device: Peripheral? {
        didSet { status = .init(device?.state) }
    }
    @Published var status: Status = .noDevice

    @Published var archive: Archive = .shared
    @Published var sortOption: SortOption = .creationDate
    @Published var sheetManager: SheetManager = .shared

    var title: String {
        device?.name ?? .noDevice
    }

    var items: [ArchiveItem] {
        archive.items.sorted {
            switch sortOption {
            case .creationDate: return $0.date > $1.date
            case .title: return $0.name < $1.name
            case .oldestFirst: return $0.date < $1.date
            case .newestFirst: return $0.date > $1.date
            }
        }
    }

    @Published var selectedCategoryIndex = 0
    @Published var isDeletePresented = false
    @Published var selectedItems: [ArchiveItem] = []
    @Published var isSelectItemsMode = false {
        didSet { onSelectItemsModeChanded(isSelectItemsMode) }
    }
    var onSelectItemsModeChanded: (Bool) -> Void = { _ in }

    @Published var editingItem: ArchiveItem = .none

    var categories: [String] = [
        "All", "RFID 125", "Sub-GHz", "NFC", "iButton", "Infrared"
    ]

    struct Group: Identifiable, Equatable {
        var id: ArchiveItem.FileType?
        var items: [ArchiveItem]
    }

    var itemGroups: [Group] {
        [
            .init(id: nil, items: items),
            .init(id: .rfid, items: items.filter { $0.fileType == .rfid }),
            .init(id: .subghz, items: items.filter { $0.fileType == .subghz }),
            .init(id: .nfc, items: items.filter { $0.fileType == .nfc }),
            .init(id: .ibutton, items: items.filter { $0.fileType == .ibutton }),
            .init(id: .irda, items: items.filter { $0.fileType == .irda })
        ]
    }

    init(onSelectItemsModeChanded: @escaping (Bool) -> Void = { _ in }) {
        self.onSelectItemsModeChanded = onSelectItemsModeChanded

        nfc.items
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newItems in
                self?.didFoundNFCTags(newItems)
            }
            .store(in: &disposeBag)

        pairedDevice.peripheral
            .receive(on: DispatchQueue.main)
            .sink { [weak self] item in
                self?.device = item
            }
            .store(in: &disposeBag)

        archive.$isSynchronizing
            .receive(on: DispatchQueue.main)
            .sink { isSynchronizing in
                self.status = isSynchronizing
                    ? .synchronizing
                    : .init(self.device?.state)
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

    func readNFCTag() {
        nfc.startReader()
    }

    func didFoundNFCTags(_ newItems: [ArchiveItem]) {
        if let item = newItems.first, !self.items.contains(item) {
            self.archive.importKey(item)
            synchronize()
        }
    }

    func shareSelectedItems() {
        if !selectedItems.isEmpty {
            share(selectedItems.map { $0.name })
        }
    }

    func deleteSelectedItems() {
        switch isSelectItemsMode {
        case true:
            selectedItems.forEach(archive.delete)
            selectedItems.removeAll()
            withAnimation {
                isSelectItemsMode = false
            }
        case false:
            archive.delete(editingItem)
            sheetManager.dismiss()
            editingItem = .none
        }
        synchronize()
    }

    func synchronize() {
        guard status == .connected else { return }
        Task {
            await archive.syncWithDevice()
        }
    }

    func favorite() {
        editingItem.isFavorite.toggle()
        archive.favorite(editingItem)
    }

    func saveChanges() {
        self.objectWillChange.send()
        editingItem.status = .modified
        archive.replace(editingItem)
    }

    func undoChanges() {
        if let item = items.first(where: { $0.id == editingItem.id }) {
            editingItem = item
        }
    }
}

extension ArchiveItem {
    static var none: Self {
        .init(
            id: .none,
            name: "",
            fileType: .ibutton,
            properties: [],
            isFavorite: false,
            status: .synchronizied)
    }
}
