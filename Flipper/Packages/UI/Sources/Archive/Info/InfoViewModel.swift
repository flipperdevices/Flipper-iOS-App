import Core
import Inject
import Peripheral
import Combine
import SwiftUI
import Logging

@MainActor
class InfoViewModel: ObservableObject {
    private let logger = Logger(label: "info-vm")

    var backup: ArchiveItem
    @Published var item: ArchiveItem
    @Published var showDumpEditor = false
    @Published var isEditing = false
    @Published var isEmulating = false
    @Published var isError = false
    var error = ""

    var isNFC: Bool {
        item.fileType == .nfc
    }

    var isEditableNFC: Bool {
        guard isNFC, let typeProperty = item.properties.first(
            where: { $0.key == "Mifare Classic type" }
        ) else {
            return false
        }
        return typeProperty.value == "1K" || typeProperty.value == "4K"
    }

    @Inject var rpc: RPC
    @Published var appState: AppState = .shared
    var dismissPublisher = PassthroughSubject<Void, Never>()
    var disposeBag = DisposeBag()

    @Published var isConnected = false
    @Published var isFlipperAppStarted = false

    init(item: ArchiveItem?) {
        self.item = item ?? .none
        self.backup = item ?? .none
        watchIsFavorite()
        watchRPCAppState()
    }

    func onAppStateChanged(_ state: Message.AppState) {
        isFlipperAppStarted = state == .started
        if state == .closed {
            isEmulating = false
        }
        logger.info("flipper app \(state)")
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
                self?.isConnected = ($0 == .connected || $0 == .synchronized)
            }
            .store(in: &disposeBag)
    }

    func watchRPCAppState() {
        rpc.onAppStateChanged { [weak self] state in
            guard let self = self else { return }
            Task { @MainActor in
                self.onAppStateChanged(state)
            }
        }

        appState.$status
            .receive(on: DispatchQueue.main)
            .filter { $0 == .disconnected }
            .sink { [weak self] _ in
                self?.resetEmulate()
            }
            .store(in: &disposeBag)
    }

    func toggleFavorite() {
        guard backup.isFavorite != item.isFavorite else { return }
        guard !isEditing else { return }
        Task {
            do {
                try await appState.archive.onIsFavoriteToggle(item.path)
            } catch {
                logger.error("toggling favorite: \(error)")
            }
        }
    }

    var emulateTaskHandle: Task<Void, Swift.Error>?

    func waitForAppStartedEvent() async throws {
        while !isFlipperAppStarted {
            try await Task.sleep(nanoseconds: 100 * 1_000_000)
        }
    }

    func startEmulate() {
        guard !isEmulating else { return }
        isEmulating = true
        emulateTaskHandle = Task {
            do {
                try Task.checkCancellation()
                try await rpc.appStart(item.fileType.application, args: "RPC")
                try Task.checkCancellation()
                try await waitForAppStartedEvent()
                try Task.checkCancellation()
                try await rpc.appLoadFile(item.path)
                if item.fileType == .subghz {
                    try Task.checkCancellation()
                    try await rpc.appButtonPress()
                }
            } catch {
                logger.error("emilating key: \(error)")
            }
        }
    }

    func stopEmulate() {
        guard isFlipperAppStarted else { return }
        guard let emulateTaskHandle = emulateTaskHandle else { return }
        self.emulateTaskHandle = nil
        emulateTaskHandle.cancel()
        Task {
            _ = await emulateTaskHandle.result
            do {
                try await rpc.appExit()
            } catch {
                logger.error("exiting the app: \(error)")
            }
        }
    }

    func resetEmulate() {
        isEmulating = false
        isFlipperAppStarted = false
    }

    func edit() {
        withAnimation {
            isEditing = true
        }
    }

    func share() {
        Core.share(item)
    }

    func delete() {
        Task {
            do {
                try await appState.archive.delete(item.id)
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
                    try await appState.archive.rename(backup.id, to: item.name)
                }
                try await appState.archive.upsert(item)
                backup = item
                withAnimation {
                    isEditing = false
                }
                item.status = .synchronizing
                try await appState.synchronize()
                withAnimation {
                    item.status = appState.archive.status(for: item)
                }
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
}
