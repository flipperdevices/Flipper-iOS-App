import Core
import Inject
import Analytics
import Combine
import SwiftUI
import Logging

@MainActor
class ImportViewModel: ObservableObject {
    private let logger = Logger(label: "import-vm")

    @Inject var analytics: Analytics

    var backup: ArchiveItem
    @Published var item: ArchiveItem
    @Published var isEditing = false
    @Published var isError = false
    var error = ""

    let appState: AppState = .shared
    var dismissPublisher = PassthroughSubject<Void, Never>()

    init(item: ArchiveItem?) {
        self.item = item ?? .none
        self.backup = item ?? .none
        recordImport()
    }

    func add() {
        guard appState.archive.get(item.id) == nil else {
            showError(Archive.Error.alreadyExists)
            return
        }
        Task {
            do {
                try await appState.importKey(item)
            } catch {
                logger.error("add key: \(error)")
            }
        }
        dismiss()
    }

    func edit() {
        withAnimation {
            isEditing = true
        }
    }

    func saveChanges() {
        backup = item
        isEditing = false
    }

    func undoChanges() {
        item = backup
        isEditing = false
    }

    func showError(_ error: Swift.Error) {
        self.error = String(describing: error)
        self.isError = true
    }

    func dismiss() {
        dismissPublisher.send(())
    }

    // Analytics

    func recordImport() {
        analytics.appOpen(target: .keyImport)
    }
}

extension ArchiveItem {
    static var none: Self {
        .init(
            name: "",
            kind: .ibutton,
            properties: [],
            shadowCopy: [])
    }
}
