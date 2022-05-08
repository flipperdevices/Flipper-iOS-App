import Core
import Combine
import SwiftUI
import Logging

@MainActor
class DeletedInfoViewModel: ObservableObject {
    private let logger = Logger(label: "deleted-info-vm")

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
                try await appState.archive.wipe(item.path)
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
