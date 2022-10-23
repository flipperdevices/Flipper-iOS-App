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
    @Published var status: DeviceStatus = .disconnected
    @Published var isEmulating = false
    @Published var isFileLoaded = false
    @Published var isFlipperAppStarted = false
    @Published var isFlipperAppCancellation = false
    @Published var isFlipperAppSystemLocked = false
    @Published var showBubble = false

    var showProgressButton: Bool {
        status == .connecting ||
        status == .synchronizing
    }

    var canEmulate: Bool {
        (status == .connected || status == .synchronized)
            && item.status == .synchronized
    }

    var forceStop = false
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
                self.status = $0
                if self.status == .disconnected {
                    self.resetEmulate()
                }
            }
            .store(in: &disposeBag)
    }

    func onAppStateChanged(_ state: Message.AppState) {
        isFlipperAppStarted = state == .started
        if state == .closed {
            resetEmulate()
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
                try await rpc.appStart(item.kind.application, args: "RPC")
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
        showBubbleIfNeeded()
        emulateTask = Task {
            do {
                try await startApp()
                try await waitForAppStartedEvent()
                try await loadFile(item.path)
                feedback(style: .soft)
                if item.kind == .subghz {
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

    func showBubbleIfNeeded() {
        guard !showBubble else { return }
        Task {
            withAnimation(.linear(duration: 0.3)) {
                showBubble = true
            }
            try await Task.sleep(seconds: 2)
            withAnimation(.linear(duration: 1)) {
                showBubble = false
            }
        }
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
                if isEmulating, item.kind == .subghz {
                    try await waitForEmulateMinimumDuration()
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

    func waitForEmulateMinimumDuration() async throws {
        let delayMilliseconds = item.isRaw
            ? emulateRawDurationRemains
            : emulateDurationRemains
        for _ in 0..<(delayMilliseconds / 10) {
            guard !forceStop else { break }
            try await Task.sleep(milliseconds: 10)
        }
    }

    func forceStopEmulate() {
        forceStop = true
        if isEmulating {
            stopEmulate()
        }
    }

    func toggleEmulate() {
        if isEmulating {
            stopEmulate()
        } else {
            startEmulate()
        }
    }

    func resetEmulate() {
        forceStop = false
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
