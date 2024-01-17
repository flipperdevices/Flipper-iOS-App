import Core
import SwiftUI

struct CategoryDeletedView: View {
    @EnvironmentObject var archive: ArchiveModel
    @Environment(\.dismiss) private var dismiss

    @State private var selectedItem: ArchiveItem?
    @State private var showDeletedView = false
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
                    showDeletedView = true
                }
                .padding(14)
            }

            NavigationLink("", isActive: $showDeletedView) {
                if let selectedItem {
                    DeletedInfoView(item: selectedItem)
                }
            }
        }
        .background(Color.background)
        .navigationBarBackground(Color.a1)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            LeadingToolbarItems {
                BackButton {
                    dismiss()
                }
            }
            PrincipalToolbarItems(alignment: .leading) {
                Title("Delete")
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
                    .confirmationDialog(
                        restoreSheetTitle,
                        isPresented: $showRestoreSheet,
                        titleVisibility: .visible
                    ) {
                        Button("Restore All") {
                            archive.restoreAll()
                        }
                    }

                    NavBarButton {
                        showDeleteSheet = true
                    } label: {
                        Text("Delete All")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(toolbarActionsColor)
                    }
                    .disabled(archive.items.isEmpty)
                    .confirmationDialog(
                        deleteSheetTitle,
                        isPresented: $showDeleteSheet,
                        titleVisibility: .visible
                    ) {
                        Button("Delete All", role: .destructive) {
                            archive.deleteAll()
                        }
                    }
                }
            }
        }
    }
}
