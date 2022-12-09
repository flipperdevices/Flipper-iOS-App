import Inject

import Combine
import Logging
import Foundation

public class ArchiveService: ObservableObject {
    private let logger = Logger(label: "archive-service")

    let appState: AppState
    @Inject var archive: Archive
    private var disposeBag: DisposeBag = .init()

    @Published public private(set) var items: [ArchiveItem] = []
    @Published public private(set) var deleted: [ArchiveItem] = []

    public init(appState: AppState) {
        self.appState = appState
        subscribeToPublishers()
    }

    func subscribeToPublishers() {
        archive.items
            .receive(on: DispatchQueue.main)
            .assign(to: \.items, on: self)
            .store(in: &disposeBag)

        archive.deletedItems
            .receive(on: DispatchQueue.main)
            .assign(to: \.deleted, on: self)
            .store(in: &disposeBag)
    }

    // MARK: Archive

    public func restoreAll() {
        Task {
            do {
                try await archive.restoreAll()
                try await appState.synchronize()
            } catch {
                logger.error("restore all: \(error)")
            }
        }
    }

    public func deleteAll() {
        Task {
            do {
                try await archive.wipeAll()
            } catch {
                logger.error("delete all: \(error)")
            }
        }
    }

    public func backupKeys() {
        archive.backupKeys()
    }
}
