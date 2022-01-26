import Core
import Combine
import Inject
import SwiftUI

@MainActor
class ArchiveBinViewModel: ObservableObject {
    @Published var appState: AppState = .shared

    @Published var deletedItems: [ArchiveItem] = []

    @Published var status: Status = .noDevice

    @Published var isActionPresented = false
    @Published var selectedItem: ArchiveItem = .none

    var disposeBag: DisposeBag = .init()

    init() {
        appState.$status
            .receive(on: DispatchQueue.main)
            .assign(to: \.status, on: self)
            .store(in: &disposeBag)

        appState.archive.$deletedItems
            .receive(on: DispatchQueue.main)
            .assign(to: \.deletedItems, on: self)
            .store(in: &disposeBag)
    }

    func synchronize() {
        Task { await appState.synchronize() }
    }

    func deleteSelectedItems() {
        guard selectedItem != .none else {
            return
        }
        appState.archive.wipe(selectedItem.id)
    }

    func restoreSelectedItems() {
        let selected = selectedItem
        guard selected != .none else {
            return
        }
        Task {
            try await appState.archive.restore(selected)
            synchronize()
        }
    }
}
