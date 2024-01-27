import Core
import SwiftUI

struct InfraredEditorView: View {
    @EnvironmentObject var archive: ArchiveModel
    @Environment(\.dismiss) private var dismiss

    @Binding var item: ArchiveItem

    @State private var remotes: [ArchiveItem.InfraredSignal] = []
    @State private var showSaveChanges = false
    @State private var error: String?

    private var canSave: Bool {
        remotes.allSatisfy { !$0.name.isEmpty }
    }

    var body: some View {
        VStack(spacing: 0) {
            Header(
                title: item.name.value,
                description: "Edit Remote",
                canSave: canSave,
                onCancel: cancel,
                onSave: save
            )
            List {
                ForEach(0 ..< remotes.count, id: \.self) { index in
                    InfraredEditorItem(
                        text: $remotes[index].name,
                        onDelete: { deleteRemote(by: index) }
                    )
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
                .onMove(perform: { indices, newOffset in
                    remotes.move(fromOffsets: indices, toOffset: newOffset)
                })
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
        .alert(item: $error) { error in
            Alert(title: Text(error))
        }
        .alert(isPresented: $showSaveChanges) {
            SaveChangesAlert(
                isPresented: $showSaveChanges,
                save: save,
                dontSave: dontSave
            )
        }
        .task {
            load()
        }
    }

    private func deleteRemote(by index: Int) {
        remotes.remove(at: index)
    }

    private func cancel() {
        if remotes != item.infraredSignals {
            showSaveChanges = true
        } else {
            dismiss()
        }
    }

    private func save() {
        item.infraredSignals = remotes
        Task {
            do {
                try await archive.save(item, as: item)
                dismiss()
            } catch {
                showError(error)
            }
        }
    }

    private func showError(_ error: Swift.Error) {
        self.error = String(describing: error)
    }

    private func dontSave() {
        dismiss()
    }

    private func load() {
        remotes = item.infraredSignals
    }
}
