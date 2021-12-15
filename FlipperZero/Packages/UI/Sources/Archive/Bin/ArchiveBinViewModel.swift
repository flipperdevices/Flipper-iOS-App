import Core
import Combine
import Inject
import SwiftUI

@MainActor
class ArchiveBinViewModel: ObservableObject {
    @Published var archive: Archive = .shared
    @Published var sheetManager: SheetManager = .shared

    var items: [ArchiveItem] {
        archive.items.filter { $0.status == .deleted }
    }

    @Published var isActionPresented = false
    @Published var isDeletePresented = false
    @Published var selectedItems: [ArchiveItem] = []
    @Published var isSelectItemsMode = false {
        didSet { onSelectItemsModeChanded(isSelectItemsMode) }
    }
    var onSelectItemsModeChanded: (Bool) -> Void = { _ in }

    @Published var selectedItem: ArchiveItem = .none

    init(onSelectItemsModeChanded: @escaping (Bool) -> Void = { _ in }) {
        self.onSelectItemsModeChanded = onSelectItemsModeChanded
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

    func shareSelectedItems() {
        if !selectedItems.isEmpty {
            share(selectedItems.map { $0.name })
        }
    }

    func deleteSelectedItems() {
        if  selectedItem != .none {
            archive.wipe(selectedItem)
        } else {
            selectedItems.forEach(archive.wipe)
            selectedItems.removeAll()
            withAnimation {
                isSelectItemsMode = false
            }
        }
    }

    func restoreSelectedItems() {
        if  selectedItem != .none {
            archive.restore(selectedItem)
        } else {
            selectedItems.forEach(archive.restore)
            selectedItems.removeAll()
            withAnimation {
                isSelectItemsMode = false
            }
        }
    }
}
