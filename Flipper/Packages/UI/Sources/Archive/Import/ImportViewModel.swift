import Core
import Inject
import Analytics
import Combine
import SwiftUI
import Logging

@MainActor
class ImportViewModel: ObservableObject {
    private let logger = Logger(label: "import-vm")

    @Inject private var appState: AppState
    @Inject private var archive: Archive
    @Inject private var analytics: Analytics
    var dismissPublisher = PassthroughSubject<Void, Never>()

    let url: URL
    @Published var state: State = .loading
    @Published var isEditing = false
    @Published var isError = false
    var error = ""

    enum State {
        case loading
        case imported
        case error(Error)
    }

    enum Error: String {
        case noInternet
        case cantConnect
    }

    @Published var item: ArchiveItem = .none
    var backup: ArchiveItem = .none

    init(url: URL) {
        self.url = url
        loadItem()
        recordImport()
    }

    func loadItem() {
        self.state = .loading
        Task { @MainActor in
            do {
                let item = try await Sharing.importKey(from: url)
                let newItem = try await archive.copyIfExists(item)
                self.item = newItem
                self.state = .imported
            } catch let error as URLError {
                switch error.code {
                case .dataNotAllowed: state = .error(.noInternet)
                default: state = .error(.cantConnect)
                }
            }
        }
    }

    func retry() {
        loadItem()
    }

    func add() {
        guard archive.get(item.id) == nil else {
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
        withAnimation {
            isEditing = false
        }
    }

    func undoChanges() {
        item = backup
        withAnimation {
            isEditing = false
        }
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
