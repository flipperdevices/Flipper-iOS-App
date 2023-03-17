import Core
import SwiftUI

@MainActor
struct DeletedInfoView: View {
    @EnvironmentObject var archive: ArchiveModel
    @Environment(\.dismiss) private var dismiss

    let item: ArchiveItem
    @State private var showDeleteSheet = false
    @State private var isEditing = false
    @State private var error: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SheetHeader(
                title: item.isNFC ? "Card Info" : "Key Info",
                description: item.name.value
            ) {
                dismiss()
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    CardView(
                        item: .init(get: { item }, set: { _ in }),
                        isEditing: $isEditing,
                        kind: .deleted
                    )
                    .padding(.top, 6)
                    .padding(.horizontal, 24)

                    VStack(alignment: .leading, spacing: 20) {
                        InfoButton(
                            image: .init("Restore"),
                            title: "Restore"
                        ) {
                            restore()
                        }
                        .foregroundColor(.primary)
                        InfoButton(
                            image: .init("Delete"),
                            title: "Delete Permanently"
                        ) {
                            delete()
                        }
                        .foregroundColor(.sRed)
                    }
                    .padding(.top, 24)
                    .padding(.horizontal, 24)

                    Spacer()
                }
            }
        }
        .alert(item: $error) { error in
            Alert(title: Text(error))
        }
        .background(Color.background)
        .edgesIgnoringSafeArea(.bottom)
    }

    func restore() {
        Task {
            do {
                try await archive.restore(item)
                dismiss()
            } catch {
                showError(error)
            }
        }
    }

    func delete() {
        Task {
            do {
                try await archive.wipe(item)
                dismiss()
            } catch {
                showError(error)
            }
        }
    }

    func showError(_ error: Swift.Error) {
        self.error = String(describing: error)
    }
}
