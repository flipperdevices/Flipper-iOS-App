import Core
import Combine
import Injector
import SwiftUI

class ArchiveViewModel: ObservableObject {
    @Inject var nfc: NFCServiceProtocol
    @Inject var storage: DeviceStorage
    @Inject var pairedDevice: PairedDeviceProtocol
    var disposeBag: DisposeBag = .init()

    @Published var device: Peripheral? {
        didSet { status = .init(device?.state) }
    }
    @Published var status: HeaderDeviceStatus = .noDevice

    @Published var archive: Archive = .shared
    @Published var sortOption: SortOption = .title
    @Published var sheetManager: SheetManager = .shared

    var title: String {
        device?.name ?? .noDevice
    }

    var items: [ArchiveItem] {
        archive.items.sorted {
//            switch sortOption {
//            case .creationDate: return $0.name < $1.name
//            case .title: return $0.description < $1.description
//            case .oldestFirst: return $0.kind < $1.kind
//            case .newestFirst: return $0.origin < $1.origin
//            }
            $0.date > $1.date
        }
    }

    @Published var isSynchronizing = false {
        willSet {
            switch newValue {
            case true: status = .synchronizing
            case false: status = .init(self.device?.state)
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
            .sink { [weak self] newItems in
                self?.didFoundNFCTags(newItems)
            }
            .store(in: &disposeBag)

        pairedDevice.peripheral
            .sink { [weak self] item in
                self?.device = item
            }
            .store(in: &disposeBag)

        archive.$isSynchronizing
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
            isSynchronizing = true
            self.archive.importKey(item) { [weak self] _ in
                self?.isSynchronizing = false
            }
        }
    }

    func shareSelectedItems() {
        if !selectedItems.isEmpty {
            share(selectedItems.map { $0.name })
        }
    }

    func deleteSelectedItems() {
        switch editingItem {
        case .none:
            selectedItems.forEach(archive.delete)
            selectedItems.removeAll()
            withAnimation {
                isSelectItemsMode = false
            }
        default:
            archive.delete(editingItem)
            sheetManager.dismiss()
            editingItem = .none
        }
    }

    func synchronize() {
        guard !isSynchronizing else {
            return
        }
        isSynchronizing = true
        archive.syncWithDevice {
            self.isSynchronizing = false
        }
    }

    func favorite() {
        editingItem.isFavorite.toggle()
        archive.favorite(editingItem)
    }
}

extension ArchiveItem {
    static var none: Self {
        .init(
            id: "",
            name: "",
            fileType: .ibutton,
            properties: [],
            status: .synchronizied)
    }
}
