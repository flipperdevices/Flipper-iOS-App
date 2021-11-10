import Core
import SwiftUI

struct ArchiveView: View {
    @StateObject var viewModel: ArchiveViewModel
    @EnvironmentObject var sheetManager: SheetManager

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
    }

    func onAction(_ action: ArchiveListView.Action) {
        switch action {
        case .itemSelected(let item): onItemSelected(item: item)
        case .horizontalDrag(let width): onDragGesture(width)
        case .synchronize: viewModel.synchronize()
        }
    }

    func onDragGesture(_ width: Double) {
        withAnimation {
            viewModel.onCardSwipe(width)
        }
    }

    func onItemSelected(item: ArchiveItem) {
        if viewModel.isSelectItemsMode {
            viewModel.selectItem(item)
        } else {
            viewModel.editingItem = item
            sheetManager.present {
                CardSheetView(
                    device: viewModel.device,
                    item: $viewModel.editingItem)
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
                    viewModel.deleteSelectedItems()
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 22))
                }
                .actionSheet(isPresented: $viewModel.isDeletePresented) {
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
