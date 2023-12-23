import Core
import SwiftUI

struct InfoView: View {
    @EnvironmentObject var archive: ArchiveModel
    @EnvironmentObject var sharing: SharingModel
    @EnvironmentObject var networkMonitor: NetworkMonitor

    @Environment(\.dismiss) private var dismiss

    let item: ArchiveItem

    @State private var current: ArchiveItem = .none
    @State private var backup: ArchiveItem = .none

    @State private var showShareKind = false
    @State private var shareItems = [Any]()

    @State private var showDumpEditor = false
    @State private var isEditing = false

    @State private var error: String?

    var body: some View {
        Group {
            if isEditing {
                EditInfoView(
                    saveChanges: saveChanges,
                    undoChanges: undoChanges,
                    current: $current,
                    isEditing: $isEditing)
            } else {
                if item.kind == .infrared {
                    InfraredInfoView(
                        onShare: shareKey,
                        onDelete: delete,
                        current: $current,
                        isEditing: $isEditing)
                } else {
                    BaseInfoView(
                        onShare: shareKey,
                        onDelete: delete,
                        onOpenNFCEdit: openNFCEditor,
                        current: $current,
                        isEditing: $isEditing)
                }
            }
        }
        .bottomSheet(isPresented: $showShareKind) {
            ShareView(item: current) { items in
                self.shareItems = items
            }
            .onAppear {
                shareItems = []
            }
            .onDisappear {
                if !shareItems.isEmpty {
                    share(shareItems)
                }
            }
            .environmentObject(sharing)
            .environmentObject(networkMonitor)
        }
        .fullScreenCover(isPresented: $showDumpEditor) {
            NFCEditorView(item: $current)
        }
        .alert(item: $error) { error in
            Alert(title: Text(error))
        }
        .background(Color.background)
        .edgesIgnoringSafeArea(.bottom)
        .onChange(of: current.isFavorite) { _ in
            toggleFavorite()
        }
        .onChange(of: archive.items) { items in
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
                try await archive.onIsFavoriteToggle(current)
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

    func delete() {
        Task {
            do {
                try await archive.delete(current)
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
                try await archive.save(backup, as: current)
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

    func shareKey() {
        showShareKind = true
    }

    func openNFCEditor() {
        showDumpEditor = true
    }
}
