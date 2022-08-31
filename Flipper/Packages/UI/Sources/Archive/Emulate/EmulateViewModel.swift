import Core
import Inject
import Analytics
import Peripheral
import SwiftUI
import Logging

@MainActor
class EmulateViewModel: ObservableObject {
    private let logger = Logger(label: "emulate-vm")

    @Inject var rpc: RPC
    @Inject var analytics: Analytics

    @Published var item: ArchiveItem
    @Published var isConnected = false
    @Published var isEmulating = false
    @Published var isFileLoaded = false
    @Published var isFlipperAppStarted = false
    @Published var isFlipperAppCancellation = false
    @Published var isFlipperAppSystemLocked = false

    var emulateStarted: Date = .now
    private var emulateTask: Task<Void, Swift.Error>?

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
            isFlipperAppCancellation = false
        }
        logger.info("flipper app \(state)")
    }

    func waitForAppStartedEvent() async throws {
        while !isFlipperAppStarted {
            try await Task.sleep(nanoseconds: 100 * 1_000_000)
        }
    }

    func startApp() async throws {
        while !isFlipperAppCancellation {
            do {
                try await rpc.appStart(item.fileType.application, args: "RPC")
                return
            } catch let error as Error {
                if error == .application(.systemLocked) {
                    isFlipperAppSystemLocked = true
                }
                throw error
            }
        }
    }

    func loadFile(_ path: Peripheral.Path) async throws {
        try await rpc.appLoadFile(path)
        isFileLoaded = true
    }

    func startEmulate() {
        guard !isEmulating else { return }
        isEmulating = true
        emulateTask = Task {
            do {
                try await startApp()
                try await waitForAppStartedEvent()
                try await loadFile(item.path)
                feedback(style: .soft)
                if item.fileType == .subghz {
                    try await rpc.appButtonPress()
                    emulateStarted = .now
                }
            } catch {
                logger.error("emilating key: \(error)")
                resetEmulate()
            }
            emulateTask = nil
        }
        recordEmulate()
    }

    // Emulated since button pressed (ms)
    var emulateDuration: Int {
        Date().timeIntervalSince(emulateStarted).ms
    }

    // Minimum for known SubGHz protocols (ms)
    var emulateMinimum: Int {
        500
    }
    var emulateDurationRemains: Int {
        max(0, emulateMinimum - emulateDuration)
    }

    // Minimum for RAW SubGHz in ms
    var emulateRawMinimum: Int {
        let durationMicroseconds = item.properties
            .filter { $0.key == "RAW_Data" }
            .map { $0.value.split(separator: " ").compactMap { Int($0) } }
            .reduce(into: []) { $0.append(contentsOf: $1) }
            .map { abs($0) }
            .reduce(0, +)
        return durationMicroseconds / 1000
    }

    var emulateRawDurationRemains: Int {
        max(0, emulateRawMinimum - emulateDuration)
    }

    func stopEmulate() {
        guard isEmulating, !isFlipperAppCancellation else { return }
        isFlipperAppCancellation = true
        Task {
            // Wait for task to complete
            _ = await emulateTask?.result
            // Try to release button
            do {
                if isEmulating, item.fileType == .subghz {
                    let delayMilliseconds = item.isRaw
                        ? emulateRawDurationRemains
                        : emulateDurationRemains
                    try await Task.sleep(milliseconds: delayMilliseconds)
                    try await rpc.appButtonRelease()
                }
            } catch {
                logger.error("release button: \(error)")
            }
            // Try to exit the app
            do {
                feedback(style: .soft)
                try await rpc.appExit()
            } catch {
                logger.error("app exit: \(error)")
            }
        }
    }

    func toggleEmulate() {
        isEmulating
            ? stopEmulate()
            : startEmulate()
    }

    func resetEmulate() {
        isEmulating = false
        isFileLoaded = false
        isFlipperAppStarted = false
        isFlipperAppCancellation = false
    }

    // Analytics

    func recordEmulate() {
        analytics.appOpen(target: .keyEmulate)
    }
}

fileprivate extension Double {
    var ms: Int {
        Int(self * 1000)
    }
}
