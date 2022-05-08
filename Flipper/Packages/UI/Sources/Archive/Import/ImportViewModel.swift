import Core
import Combine
import SwiftUI
import Logging

@MainActor
class ImportViewModel: ObservableObject {
    private let logger = Logger(label: "import-vm")

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

    func add() {
        guard appState.archive.get(item.id) == nil else {
            showError(Archive.Error.alredyExists)
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
            isEditMode = true
        }
    }

    func saveChanges() {
        backup = item
        isEditMode = false
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

extension ArchiveItem {
    static var none: Self {
        .init(
            name: "",
            fileType: .ibutton,
            properties: [])
    }
}
