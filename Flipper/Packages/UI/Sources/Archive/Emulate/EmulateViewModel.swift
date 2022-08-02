import Core
import Inject
import Peripheral
import SwiftUI
import Logging

@MainActor
class EmulateViewModel: ObservableObject {
    private let logger = Logger(label: "emulate-vm")
    @Inject var rpc: RPC

    @Published var item: ArchiveItem
    @Published var isConnected = false
    @Published var isEmulating = false
    @Published var isFlipperAppStarted = false
    private var emulateTaskHandle: Task<Void, Swift.Error>?

    @Published var appState: AppState = .shared
    var disposeBag = DisposeBag()

    init(item: ArchiveItem) {
        self.item = item

        rpc.onAppStateChanged { [weak self] state in
            guard let self = self else { return }
            Task { @MainActor in
                self.onAppStateChanged(state)
            }
        }

        appState.$status
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self = self else { return }
                self.isConnected = ($0 == .connected || $0 == .synchronized)
                if $0 == .disconnected {
                    self.resetEmulate()
                }
            }
            .store(in: &disposeBag)
    }

    func onAppStateChanged(_ state: Message.AppState) {
        isFlipperAppStarted = state == .started
        if state == .closed {
            isEmulating = false
        }
        logger.info("flipper app \(state)")
    }

    func waitForAppStartedEvent() async throws {
        while !isFlipperAppStarted {
            try await Task.sleep(nanoseconds: 100 * 1_000_000)
        }
    }

    func startApp() async throws {
        while !Task.isCancelled {
            do {
                try await rpc.appStart(item.fileType.application, args: "RPC")
                return
            } catch let error as Error {
                if error == .application(.systemLocked) {
                    try await Task.sleep(nanoseconds: 100 * 1_000_000)
                    continue
                }
                throw error
            }
        }
    }

    func startEmulate() {
        guard !isEmulating else { return }
        isEmulating = true
        emulateTaskHandle = Task {
            do {
                try Task.checkCancellation()
                try await startApp()
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
}
