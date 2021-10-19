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
                    isEditing: $viewModel.isEditing,
                    selectedItems: $viewModel.selectedItems,
                    itemSelected: onItemSelected,
                    onDragGesture: onDragGesture)
            }

            if viewModel.isEditing {
                tabViewOverlay
            }
        }
    }

    func onDragGesture(_ value: DragGesture.Value) {
        withAnimation {
            viewModel.onCardSwipe(value.translation.width)
        }
    }

    func onItemSelected(item: ArchiveItem) {
        if viewModel.isEditing {
            viewModel.selectItem(item)
        } else {
            sheetManager.present {
                CardSheetView(item: item)
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
