import Core
import Inject
import Combine
import SwiftUI
import Logging

@MainActor
class SaveAsViewModel: ObservableObject {
    private let logger = Logger(label: "save-as-vm")

    var item: Binding<ArchiveItem>

    @Published var isError = false
    var error = ""

    var appState: AppState = .shared
    var archive: Archive { appState.archive }

    var dismissPublisher: PassthroughSubject<Void, Never>

    init(
        item: Binding<ArchiveItem>,
        dismissPublisher: PassthroughSubject<Void, Never>
    ) {
        self.item = item
        self.dismissPublisher = dismissPublisher
    }

    func save() {
        Task {
            do {
                // (ノಠ益ಠ)ノ彡┻━┻
<<<<<<< HEAD
                guard archive.get(item.id) == nil else {
                    showError(Archive.Error.alreadyExists)
=======
                guard archive.get(item.wrappedValue.id) == nil else {
                    showError(Archive.Error.alredyExists)
>>>>>>> 8183363 (iOS 14 lazy backport)
                    return
                }
                try await archive.upsert(item.wrappedValue)
                dismiss()
                try await appState.synchronize()
            } catch {
                logger.error("save as: \(error)")
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
