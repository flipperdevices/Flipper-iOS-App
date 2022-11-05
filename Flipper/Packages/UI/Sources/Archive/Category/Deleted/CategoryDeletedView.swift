import Core
import SwiftUI

struct CategoryDeletedView: View {
    @StateObject var viewModel: CategoryDeletedViewModel
    @Environment(\.dismiss) private var dismiss

    var restoreSheetTitle: String {
        "All deleted keys will be restored and synced with Flipper"
    }

    var deleteSheetTitle: String {
        "All this keys will be deleted.\nThis action cannot be undone."
    }

    var toolbarActionsColor: Color {
        viewModel.items.isEmpty ? .primary.opacity(0.5) : .primary
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
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            LeadingToolbarItems {
                BackButton {
                    dismiss()
                }
                Title("Deleted")
            }
            TrailingToolbarItems {
                NavBarButton {
                    viewModel.showRestoreSheet = true
                } label: {
                    Text("Restore All")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(toolbarActionsColor)
                }
                .disabled(viewModel.items.isEmpty)
                .actionSheet(isPresented: $viewModel.showRestoreSheet) {
                    .init(title: Text(restoreSheetTitle), buttons: [
                        .destructive(Text("Restore All")) {
                            viewModel.restoreAll()
                        },
                        .cancel()
                    ])
                }

                NavBarButton {
                    viewModel.showDeleteSheet = true
                } label: {
                    Text("Delete All")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(toolbarActionsColor)
                }
                .disabled(viewModel.items.isEmpty)
                .actionSheet(isPresented: $viewModel.showDeleteSheet) {
                    .init(title: Text(deleteSheetTitle), buttons: [
                        .destructive(Text("Delete All")) {
                            viewModel.deleteAll()
                        },
                        .cancel()
                    ])
                }
            }
        }
        .sheet(isPresented: $viewModel.showInfoView) {
            DeletedInfoView(viewModel: .init(item: viewModel.selectedItem))
        }
    }
}
