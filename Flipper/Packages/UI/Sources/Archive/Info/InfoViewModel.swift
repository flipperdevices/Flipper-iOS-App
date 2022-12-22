import Core
import Inject
import Analytics
import Peripheral
import Combine
import SwiftUI
import Logging

@MainActor
class InfoViewModel: ObservableObject {
    private let logger = Logger(label: "info-vm")

    @Inject var analytics: Analytics

    var backup: ArchiveItem
    @Published var item: ArchiveItem
    @Published var showShareView = false
    @Published var showDumpEditor = false
    @Published var isEditing = false
    @Published var isError = false
    var error = ""

    @Inject private var rpc: RPC
    @Inject private var appState: AppState
    @Inject private var archive: Archive
    var dismissPublisher = PassthroughSubject<Void, Never>()
    var disposeBag = DisposeBag()

    @Published var isConnected = false

    init(item: ArchiveItem) {
        self.item = item
        self.backup = item
        watchIsFavorite()
    }

    func watchIsFavorite() {
        $item
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.toggleFavorite()
            }
            .store(in: &disposeBag)

        appState.$status
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self else { return }
                self.isConnected = ($0 == .connected || $0 == .synchronized)
                self.updateItemStatus(deviceStatus: $0)
            }
            .store(in: &disposeBag)
    }

    func updateItemStatus(deviceStatus: DeviceStatus) {
        if deviceStatus == .synchronizing {
            self.item.status = .synchronizing
        } else {
            Task { @MainActor in
                item.status = try await archive.status(for: item)
            }
        }
    }

    func toggleFavorite() {
        guard backup.isFavorite != item.isFavorite else { return }
        guard !isEditing else { return }
        Task {
            do {
                try await archive.onIsFavoriteToggle(item.path)
            } catch {
                logger.error("toggling favorite: \(error)")
            }
        }
    }

    func edit() {
        backup = item
        withAnimation {
            isEditing = true
        }
        recordEdit()
    }

    func share() {
        showShareView = true
    }

    func delete() {
        Task {
            do {
                try await archive.delete(item.id)
                try await appState.synchronize()
            } catch {
                logger.error("deleting item: \(error)")
            }
        }
        dismiss()
    }

    func saveChanges() {
        guard item != backup else {
            withAnimation {
                isEditing = false
            }
            return
        }
        Task {
            do {
                if backup.name != item.name {
                    try await archive.rename(backup.id, to: item.name)
                }
                try await archive.upsert(item)
                withAnimation {
                    isEditing = false
                }
                try await appState.synchronize()
            } catch {
                logger.error("saving changes: \(error)")
                item.status = .error
                showError(error)
            }
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

    func recordEdit() {
        analytics.appOpen(target: .keyEdit)
    }
}

extension ArchiveItem {
    var isNFC: Bool {
        kind == .nfc
    }

    var isEditableNFC: Bool {
        guard isNFC, let typeProperty = properties.first(
            where: { $0.key == "Mifare Classic type" }
        ) else {
            return false
        }
        return typeProperty.value == "1K" || typeProperty.value == "4K"
    }
}
