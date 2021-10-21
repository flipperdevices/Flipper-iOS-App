import Core
import Combine
import Injector
import SwiftUI

class ArchiveViewModel: ObservableObject {
    @Inject var nfc: NFCServiceProtocol
    @Inject var storage: DeviceStorage
    @Inject var pairedDevice: PairedDeviceProtocol
    var disposeBag: DisposeBag = .init()

    @Published var device: Peripheral?

    @Published var archive: Archive = .init()
    @Published var sortOption: SortOption = .title

    var items: [ArchiveItem] {
        archive.items.sorted {
            switch sortOption {
            case .creationDate: return $0.name < $1.name
            case .title: return $0.description < $1.description
            case .oldestFirst: return $0.kind < $1.kind
            case .newestFirst: return $0.origin < $1.origin
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

    @Published var editingItem: ArchiveItem = .demo

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
        self.onSelectItemsModeChanded = onSelectItemsModeChanded

        nfc.items
            .sink { [weak self] newItems in
                guard let self = self else { return }
                if let item = newItems.first, !self.items.contains(item) {
                    self.archive.append(item)
                }
            }
            .store(in: &disposeBag)

        pairedDevice.peripheral
            .sink { [weak self] item in
                self?.device = item
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

extension ArchiveItem {
    static var demo: Self {
        .init(
            id: "",
            name: "",
            description: "",
            isFavorite: false,
            kind: .ibutton,
            origin: "")
    }
}
