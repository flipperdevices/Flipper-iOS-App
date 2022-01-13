import Core
import SwiftUI

struct ArchiveBinView: View {
    @StateObject var viewModel: ArchiveBinViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(viewModel.deletedItems) { item in
                    Button {
                        onItemSelected(item: item)
                    } label: {
                        ArchiveListItemView(item: item)
                            .foregroundColor(.primary)
                            .background(systemBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal, 16)
                }
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
    }

    func onItemSelected(item: ArchiveItem) {
        viewModel.selectedItem = item
        viewModel.isActionPresented = true
    }
}
