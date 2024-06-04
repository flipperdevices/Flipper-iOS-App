import Core
import SwiftUI

struct CategoryDeletedView: View {
    @EnvironmentObject var archive: ArchiveModel
    @Environment(\.path) private var path
    @Environment(\.dismiss) private var dismiss

    @State private var showRestoreSheet = false
    @State private var showDeleteSheet = false

    var restoreSheetTitle: String {
        "All deleted keys will be restored and synced with Flipper"
    }

    var deleteSheetTitle: String {
        "All this keys will be deleted.\nThis action cannot be undone."
    }

    var toolbarActionsColor: Color {
        archive.deleted.isEmpty ? .primary.opacity(0.5) : .primary
    }

    var body: some View {
        ZStack {
            Text("No deleted keys")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.black40)
                .opacity(archive.deleted.isEmpty ? 1 : 0)

            ScrollView {
                CategoryList(items: archive.deleted) { item in
                    path.append(ArchiveView.Destination.infoDeleted(item))
                }
                .padding(14)
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
                .disabled(archive.deleted.isEmpty)
            }
        }
    }
}
