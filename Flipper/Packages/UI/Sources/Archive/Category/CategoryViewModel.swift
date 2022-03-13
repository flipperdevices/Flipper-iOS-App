import Core
import Combine

class CategoryViewModel: ObservableObject {
    let name: String
    let items: [ArchiveItem]

    var selectedItem: ArchiveItem?
    @Published var showInfoView = false

    init(name: String, items: [ArchiveItem]) {
        self.name = name
        self.items = items
    }

    func onItemSelected(item: ArchiveItem) {
        selectedItem = item
        showInfoView = true
    }
}
