import Core
import Combine
import Inject
import SwiftUI

@MainActor
class ArchiveViewModel: ObservableObject {
    @Inject var nfc: NFCService
    var disposeBag: DisposeBag = .init()

    @Published var device: Peripheral?
    @Published var status: Status = .noDevice

    @Published var appState: AppState = .shared
    @Published var sortOption: SortOption = .creationDate
    @Published var sheetManager: SheetManager = .shared

    var archive: Archive { appState.archive }
    var title: String { device?.name ?? .noDevice }

    @Published var items: [ArchiveItem] = []
    @Published var selectedCategoryIndex = 0
    @Published var isDeletePresented = false
    @Published var selectedItems: [ArchiveItem] = []
    @Published var isSelectItemsMode = false {
        didSet { onSelectItemsModeChanded(isSelectItemsMode) }
    }
    var onSelectItemsModeChanded: (Bool) -> Void = { _ in }

    @Published var editingItem: EditingItem = .none

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

        appState.$device
            .receive(on: DispatchQueue.main)
            .assign(to: \.device, on: self)
            .store(in: &disposeBag)

        appState.$status
            .receive(on: DispatchQueue.main)
            .assign(to: \.status, on: self)
            .store(in: &disposeBag)

        appState.archive.$items
            .receive(on: DispatchQueue.main)
            .map { items in
                items.sorted {
                    switch self.sortOption {
                    case .creationDate: return $0.date > $1.date
                    case .title: return $0.name < $1.name
                    case .oldestFirst: return $0.date < $1.date
                    case .newestFirst: return $0.date > $1.date
                    }
                }
            }
            .assign(to: \.items, on: self)
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
            Task {
                try await appState.importKey(item)
                synchronize()
            }
        }
    }

    func shareSelectedItems() {
        if !selectedItems.isEmpty {
            // sharing multiple files is not supported atm
        }
    }

    func deleteSelectedItems() {
        Task {
            switch isSelectItemsMode {
            case true:
                for item in selectedItems {
                    try await archive.delete(item.id)
                }
                selectedItems.removeAll()
                withAnimation {
                    isSelectItemsMode = false
                }
            case false:
                try await archive.delete(editingItem.id)
                sheetManager.dismiss()
                editingItem = .none
            }
            synchronize()
        }
    }

    func synchronize() {
        Task { await appState.synchronize() }
    }

    func favorite() {
        editingItem.isFavorite.toggle()
        archive.favorite(editingItem.id)
    }

    func saveChanges() {
        Task {
            self.objectWillChange.send()

            guard editingItem.isRenamed else {
                try await archive.upsert(editingItem.value)
                return
            }

            let name = editingItem.name.filterInvalidCharacters()
            if archive.items.contains(where: { $0.name.value == name }) {
                undoChanges()
            } else {
                try await archive.upsert(editingItem.value)
                try await archive.rename(editingItem.id, to: name)
            }

            synchronize()
        }
    }

    func undoChanges() {
        if let item = items.first(where: { $0.id == editingItem.id }) {
            editingItem = .init(item)
        }
    }
}

extension ArchiveItem {
    static var none: Self {
        .init(
            name: "",
            fileType: .ibutton,
            properties: [])
    }
}

fileprivate extension String {
    var allowed: [Character] { .init("abcdefghijklmnopqrstuvwxyz1234567890_") }

    func filterInvalidCharacters() -> String {
        guard !isEmpty else { return "" }
        let name = lowercased().filter { allowed.contains($0) }
        return name.prefix(1).uppercased() + name.dropFirst()
    }
}
