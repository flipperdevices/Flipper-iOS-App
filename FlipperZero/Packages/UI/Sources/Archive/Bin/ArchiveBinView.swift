import Core
import SwiftUI

struct ArchiveBinView: View {
    @StateObject var viewModel: ArchiveBinViewModel

    var body: some View {
        VStack(spacing: 0) {
            ArchiveListView(
                status: .noDevice,
                items: viewModel.archive.bin.items,
                hasFavorites: false,
                isSelectItemsMode: $viewModel.isSelectItemsMode,
                selectedItems: $viewModel.selectedItems,
                onAction: onAction)

            if viewModel.isSelectItemsMode {
                tabViewOverlay
            }
        }
        .navigationTitle("Deleted items")
        .navigationBarTitleDisplayMode(.inline)
        .actionSheet(isPresented: $viewModel.isActionPresented) {
            .init(title: Text("Be careful"), buttons: [
                .default(Text("Restore")) {
                    viewModel.restoreSelectedItems()
                },
                .destructive(Text("Delete")) {
                    viewModel.deleteSelectedItems()
                },
                .cancel()
            ])
        }
        .navigationBarItems(trailing: rightView)
    }

    @ViewBuilder var rightView: some View {
        if viewModel.isSelectItemsMode {
            Button {
                withAnimation {
                    viewModel.isSelectItemsMode = false
                }
            } label: {
                Text("Done")
                    .fontWeight(.medium)
                    .padding(.leading, UIDevice.isFaceIDAvailable ? 15.5 : 14)
            }
        } else {
            Button {
                viewModel.isSelectItemsMode = true
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
    }

    func onAction(_ action: ArchiveListView.Action) {
        switch action {
        case .itemSelected(let item): onItemSelected(item: item)
        case .synchronize: break
        }
    }

    func onItemSelected(item: ArchiveItem) {
        if viewModel.isSelectItemsMode {
            viewModel.selectItem(item)
        } else {
            viewModel.selectedItem = item
            viewModel.isActionPresented = true
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
