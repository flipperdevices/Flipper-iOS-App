import Core
import SwiftUI

struct ArchiveView: View {
    @ObservedObject var viewModel: ArchiveViewModel
    @EnvironmentObject var sheetManager: SheetManager

    init(viewModel: ArchiveViewModel) {
        self.viewModel = viewModel
    }

    var categories: [String] = [
        "Favorites", "RFID 125", "Sub-gHz", "NFC", "iButton", "iRda"
    ]
    @State var selectedCategory: String = "Favorites"

    var body: some View {
        VStack {
            ArchiveHeaderView(
                device: viewModel.device,
                onOptions: viewModel.openOptions,
                onAddItem: viewModel.readNFCTag)
            ArchiveCategoriesView(
                categories: categories,
                selected: $selectedCategory)
            ArchiveListView { item in
                sheetManager.present {
                    CardSheetView(item: item)
                }
            }
        }
    }
}

struct ArchiveView_Previews: PreviewProvider {
    static var previews: some View {
        ArchiveView(viewModel: .init())
    }
}
