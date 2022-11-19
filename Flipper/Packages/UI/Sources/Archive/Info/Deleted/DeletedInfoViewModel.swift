import Core
import Inject
import Combine
import SwiftUI
import Logging

@MainActor
class DeletedInfoViewModel: ObservableObject {
    private let logger = Logger(label: "deleted-info-vm")

    @Inject private var archive: Archive

    @Published var item: ArchiveItem
    @Published var showDeleteSheet = false
    @Published var isEditing = false
    @Published var isError = false
    var error = ""

    @Inject private var appState: AppState
    var dismissPublisher = PassthroughSubject<Void, Never>()

    init(item: ArchiveItem) {
        self.item = item
    }

    func restore() {
        Task {
            do {
                try await archive.restore(item)
                dismiss()
                try await appState.synchronize()
            } catch {
                logger.error("restore item: \(error)")
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
                logger.error("wipe item: \(error)")
                showError(error)
            }
        }
    }

    func showError(_ error: Swift.Error) {
        self.error = String(describing: error)
        self.isError = true
    }

    func dismiss() {
        dismissPublisher.send(())
    }
}
