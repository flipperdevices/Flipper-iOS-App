import Core
import SwiftUI

struct ArchiveView: View {
    @StateObject var viewModel: ArchiveViewModel

    var body: some View {
        VStack(spacing: 0) {
            ArchiveHeaderView(
                viewModel: viewModel)
            ArchiveCategoriesView(
                categories: viewModel.categories,
                selectedIndex: $viewModel.selectedCategoryIndex)
            Divider()
            CarouselView(
                spacing: 0,
                index: $viewModel.selectedCategoryIndex,
                items: viewModel.itemGroups
            ) { group in
                ArchiveListView(
                    items: group.items,
                    isSynchronizing: viewModel.isSynchronizing,
                    isSelectItemsMode: $viewModel.isSelectItemsMode,
                    selectedItems: $viewModel.selectedItems,
                    onAction: onAction)
            }

            if viewModel.isSelectItemsMode {
                tabViewOverlay
            }
        }
        .actionSheet(isPresented: $viewModel.isDeletePresented) {
            .init(title: Text("You can't undo this action"), buttons: [
                .destructive(Text("Delete")) {
                    viewModel.deleteSelectedItems()
                },
                .cancel()
            ])
        }
    }

    func onAction(_ action: ArchiveListView.Action) {
        switch action {
        case .itemSelected(let item): onItemSelected(item: item)
        case .synchronize: viewModel.synchronize()
        }
    }

    func onItemSelected(item: ArchiveItem) {
        if viewModel.isSelectItemsMode {
            viewModel.selectItem(item)
        } else {
            viewModel.editingItem = item
            viewModel.sheetManager.present {
                CardSheetView(viewModel: viewModel)
            }
        }
    }

    var tabViewOverlay: some View {
        VStack {
            HStack(alignment: .center) {
                Button {
                    viewModel.shareSelectedItems()
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 22))
                }

                Spacer()
                Text("Chosen \(viewModel.selectedItems.count) objects")
                    .font(.system(size: 17, weight: .semibold))
                Spacer()

                Button {
                    viewModel.isDeletePresented = true
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 22))
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
