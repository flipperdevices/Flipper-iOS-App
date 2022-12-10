import Core
import SwiftUI

struct InfoView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var archiveService: ArchiveService
    @StateObject var alertController: AlertController = .init()
    @Environment(\.dismiss) private var dismiss

    let item: ArchiveItem

    @State private var current: ArchiveItem = .none
    @State private var backup: ArchiveItem = .none
    @State private var showShareView = false
    @State private var showDumpEditor = false
    @State private var isEditing = false
    @State private var error: String?

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                if isEditing {
                    SheetEditHeader(
                        title: "Editing",
                        description: current.name.value,
                        onSave: saveChanges,
                        onCancel: undoChanges
                    )
                } else {
                    SheetHeader(
                        title: current.isNFC ? "Card Info" : "Key Info",
                        description: current.name.value
                    ) {
                        dismiss()
                    }
                }

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        CardView(
                            item: $current,
                            isEditing: $isEditing,
                            kind: .existing
                        )
                        .padding(.top, 6)
                        .padding(.horizontal, 24)

                        EmulateView(item: item)
                            .opacity(isEditing ? 0 : 1)
                            .environmentObject(alertController)

                        VStack(alignment: .leading, spacing: 2) {
                            if current.isEditableNFC {
                                InfoButton(
                                    image: "HexEditor",
                                    title: "Edit Dump"
                                ) {
                                    showDumpEditor = true
                                }
                                .foregroundColor(.primary)
                            }
                            InfoButton(
                                image: "Share",
                                title: "Share"
                            ) {
                                share()
                            }
                            .foregroundColor(.primary)
                            InfoButton(
                                image: "Delete",
                                title: "Delete"
                            ) {
                                delete()
                            }
                            .foregroundColor(.sRed)
                        }
                        .padding(.top, 8)
                        .padding(.horizontal, 24)
                        .opacity(isEditing ? 0 : 1)

                        Spacer()
                    }
                }
            }

            if alertController.isPresented {
                alertController.alert
            }
        }
        .bottomSheet(isPresented: $showShareView) {
            ShareView(viewModel: .init(item: current))
        }
        .fullScreenCover(isPresented: $showDumpEditor) {
            NFCEditorView(item: $current)
        }
        .alert(item: $error) { error in
            Alert(title: Text(error))
        }
        .background(Color.background)
        .edgesIgnoringSafeArea(.bottom)
        .environmentObject(alertController)
        .onChange(of: current.isFavorite) { _ in
            toggleFavorite()
        }
        .onChange(of: archiveService.items) { items in
            if let item = items.first(where: { $0.id == current.id }) {
                self.current.status = item.status
            }
        }
        .task {
            self.current = item
            self.backup = item
        }
    }

    func toggleFavorite() {
        Task {
            do {
                guard backup.isFavorite != current.isFavorite else { return }
                guard !isEditing else { return }
                backup.isFavorite = current.isFavorite
                try await archiveService.onIsFavoriteToggle(current)
            } catch {
                showError(error)
            }
        }
    }

    func edit() {
        backup = current
        withAnimation {
            isEditing = true
        }
    }

    func share() {
        showShareView = true
    }

    func delete() {
        Task {
            do {
                try await archiveService.delete(current)
                dismiss()
            } catch {
                showError(error)
            }
        }
    }

    func saveChanges() {
        guard current != backup else {
            withAnimation {
                isEditing = false
            }
            return
        }
        Task {
            do {
                try await archiveService.save(backup, as: current)
                withAnimation {
                    isEditing = false
                }
            } catch {
                current.status = .error
                showError(error)
            }
        }
    }

    func undoChanges() {
        current = backup
        withAnimation {
            isEditing = false
        }
    }

    func showError(_ error: Swift.Error) {
        self.error = String(describing: error)
    }
}

extension ArchiveItem {
    var isNFC: Bool {
        kind == .nfc
    }

    var isEditableNFC: Bool {
        guard isNFC, let typeProperty = properties.first(
            where: { $0.key == "Mifare Classic type" }
        ) else {
            return false
        }
        return typeProperty.value == "1K" || typeProperty.value == "4K"
    }
}
