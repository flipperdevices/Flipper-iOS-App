import Core
import Combine
import SwiftUI

@MainActor
class InfoViewModel: ObservableObject {
    var backup: ArchiveItem
    @Published var item: ArchiveItem
    @Published var isEditMode = false
    @Published var isError = false
    var error = ""

    let appState: AppState = .shared
    var dismissPublisher = PassthroughSubject<Void, Never>()

    init(item: ArchiveItem?) {
        self.item = item ?? .none
        self.backup = item ?? .none
    }

    func edit() {
        withAnimation {
            isEditMode = true
        }
    }

    func share() {
        Core.share(item)
    }

    func delete() {
        Task {
            try await appState.archive.delete(item.id)
            await appState.synchronize()
        }
        dismiss()
    }

    func saveChanges() {
        Task {
            do {
                if backup.name != item.name {
                    try await appState.archive.rename(backup.id, to: item.name)
                }
                try await appState.archive.upsert(item)
                backup = item
                isEditMode = false
                await appState.synchronize()
            } catch {
                showError(error)
            }
        }
    }

    func undoChanges() {
        item = backup
        isEditMode = false
    }

    func showError(_ error: Swift.Error) {
        self.error = String(describing: error)
        self.isError = true
    }

    func dismiss() {
        dismissPublisher.send(())
    }
}
