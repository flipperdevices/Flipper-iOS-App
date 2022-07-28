import Core
import SwiftUI

struct CategoryDeletedView: View {
    @StateObject var viewModel: CategoryDeletedViewModel
    @Environment(\.dismiss) var dismiss

    var sheetTitle: String {
        "All this keys will be deleted.\nThis action cannot be undone."
    }

    var body: some View {
        ZStack {
            Text("No deleted keys")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.black40)
                .opacity(viewModel.items.isEmpty ? 1 : 0)

            ScrollView {
                CategoryList(items: viewModel.items) { item in
                    viewModel.onItemSelected(item: item)
                }
                .padding(14)
            }
        }

        .background(Color.background)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton {
                    dismiss()
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Text("Deleted")
                    .font(.system(size: 20, weight: .bold))
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.showDeleteSheet = true
                } label: {
                    Text("Delete all")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.primary)
                }
            }
        }
        .actionSheet(isPresented: $viewModel.showDeleteSheet) {
            .init(title: Text(sheetTitle), buttons: [
                .destructive(Text("Delete All")) {
                    viewModel.deleteAll()
                },
                .cancel()
            ])
        }
        .sheet(isPresented: $viewModel.showInfoView) {
            DeletedInfoView(viewModel: .init(item: viewModel.selectedItem))
        }
    }
}
