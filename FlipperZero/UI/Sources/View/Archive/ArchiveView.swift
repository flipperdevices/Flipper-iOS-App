import Core
import SwiftUI

struct ArchiveView: View {
    @StateObject var viewModel: ArchiveViewModel
    @EnvironmentObject var sheetManager: SheetManager

    var categories: [String] = [
        "Favorites", "RFID 125", "Sub-gHz", "NFC", "iButton", "iRda"
    ]
    @State var selectedCategory: String = "Favorites"
    @State var isDeletePresented: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            ArchiveHeaderView(
                device: viewModel.device,
                isEditing: $viewModel.isEditing,
                onOptions: viewModel.openOptions,
                onAddItem: viewModel.readNFCTag)
            ArchiveCategoriesView(
                categories: categories,
                selected: $selectedCategory)
            Divider()
            ArchiveListView(
                isEditing: $viewModel.isEditing,
                selectedItems: $viewModel.selectedItems
            ) { item in
                if viewModel.isEditing {
                    viewModel.selectItem(item)
                } else {
                    sheetManager.present {
                        CardSheetView(item: item)
                    }
                }
            }

            if viewModel.isEditing {
                tabViewOverlay
            }
        }
    }

    var tabViewOverlay: some View {
        VStack {
            HStack(alignment: .center) {
                Button {
                    if !viewModel.selectedItems.isEmpty {
                        share(viewModel.selectedItems.map { $0.name })
                    }
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 22))
                }

                Spacer()
                Text("Chosen \(viewModel.selectedItems.count) objects")
                    .font(.system(size: 17, weight: .semibold))
                Spacer()

                Button {
                    if !viewModel.selectedItems.isEmpty {
                        isDeletePresented = true
                    }
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 22))
                }
                .actionSheet(isPresented: $isDeletePresented) {
                    .init(title: Text("You can't undo this action"), buttons: [
                        .destructive(Text("Delete")) { print("delete") },
                        .cancel()
                    ])
                }
            }
            .padding(.top, 12)
            .padding(.bottom, bottomSafeArea)
            .padding(.horizontal, 22)
        }
        .frame(height: tabViewHeight + bottomSafeArea + 8, alignment: .top)
        .background(systemBackground)
    }
}

struct ArchiveView_Previews: PreviewProvider {
    static var previews: some View {
        ArchiveView(viewModel: .init())
    }
}
