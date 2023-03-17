import Core
import SwiftUI

struct CategoryDeletedView: View {
    @EnvironmentObject var archive: ArchiveModel
    @Environment(\.dismiss) private var dismiss

    @State private var selectedItem: ArchiveItem?
    @State private var showRestoreSheet = false
    @State private var showDeleteSheet = false

    var restoreSheetTitle: String {
        "All deleted keys will be restored and synced with Flipper"
    }

    var deleteSheetTitle: String {
        "All this keys will be deleted.\nThis action cannot be undone."
    }

    var toolbarActionsColor: Color {
        archive.items.isEmpty ? .primary.opacity(0.5) : .primary
    }

    var body: some View {
        ZStack {
            Text("No deleted keys")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.black40)
                .opacity(archive.items.isEmpty ? 1 : 0)

            ScrollView {
                CategoryList(items: archive.deleted) { item in
                    selectedItem = item
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
                HStack(spacing: 8) {
                    NavBarButton {
                        showRestoreSheet = true
                    } label: {
                        Text("Restore All")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(toolbarActionsColor)
                    }
                    .disabled(archive.items.isEmpty)
                    .actionSheet(isPresented: $showRestoreSheet) {
                        .init(title: Text(restoreSheetTitle), buttons: [
                            .destructive(Text("Restore All")) {
                                archive.restoreAll()
                            },
                            .cancel()
                        ])
                    }

                    NavBarButton {
                        showDeleteSheet = true
                    } label: {
                        Text("Delete All")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(toolbarActionsColor)
                    }
                    .disabled(archive.items.isEmpty)
                    .actionSheet(isPresented: $showDeleteSheet) {
                        .init(title: Text(deleteSheetTitle), buttons: [
                            .destructive(Text("Delete All")) {
                                archive.deleteAll()
                            },
                            .cancel()
                        ])
                    }
                }
            }
        }
        .sheet(item: $selectedItem) { item in
            DeletedInfoView(item: item)
        }
    }
}
