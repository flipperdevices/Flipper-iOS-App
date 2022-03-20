import Core
import Combine
import SwiftUI

@MainActor
class DeletedInfoViewModel: ObservableObject {
    @Published var item: ArchiveItem
    @Published var showDeleteSheet = false
    @Published var isError = false
    var error = ""

    let appState: AppState = .shared
    var dismissPublisher = PassthroughSubject<Void, Never>()

    init(item: ArchiveItem?) {
        self.item = item ?? .none
    }

    func restore() {
        Task {
            do {
                try await appState.archive.restore(item)
                dismiss()
                await appState.synchronize()
            } catch {
                showError(error)
            }
        }
    }

    func delete() {
        Task {
            try await appState.archive.wipe(item.id)
        }
        dismiss()
    }

    func showError(_ error: Swift.Error) {
        self.error = String(describing: error)
        self.isError = true
    }

    func dismiss() {
        dismissPublisher.send(())
    }
}
