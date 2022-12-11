import Inject
import Analytics
import Peripheral
import Combine
import Logging
import Foundation

@MainActor
public class EmulateService: ObservableObject {
    private let logger = Logger(label: "emulate")

    let appState: AppState

    var emulate: EmulateModel {
        get { appState.emulate }
        set { appState.emulate = newValue }
    }

    @Inject private var rpc: RPC
    @Inject private var analytics: Analytics
    private var disposeBag: DisposeBag = .init()

    var item: ArchiveItem?

    private var stop = false
    private var forceStop = false
    private var emulateTask: Task<Void, Swift.Error>?
    private var emulateStarted: Date = .now

    public init(appState: AppState) {
        self.appState = appState
        subscribeToPublishers()
    }

    func subscribeToPublishers() {
        rpc.onAppStateChanged { [weak self] state in
            guard let self else { return }
            Task { @MainActor in
                self.onFlipperAppStateChanged(state)
            }
        }
    }

    func onFlipperAppStateChanged(_ state: Message.AppState) {
        switch state {
        case .started:
            emulate.state = .started
        case .closed:
            emulate.state = .closed
            resetEmulate()
        case .unknown: logger.critical("unknown app state")
        }
    }

    public func startEmulate(_ item: ArchiveItem) {
        guard self.item == nil else {
            return
        }
        self.item = item
        emulateTask = Task {
            do {
                try await startApp(item.kind.application)
                try await loadFile(item.path)
                try await startLoaded(item)
                recordEmulate()
            } catch {
                logger.error("emilating key: \(error)")
                resetEmulate()
            }
            emulateTask = nil
        }
    }

    public func stopEmulate() {
        guard !stop else { return }
        self.stop = true
        Task {
            // Wait for task to complete
            _ = await emulateTask?.result
            // Try to release button
            do {
                if let item = item {
                    try await stopLoaded(item)
                }
            } catch {
                logger.error("release button: \(error)")
            }
            // Try to exit the app
            do {
                try await exitApp()
            } catch {
                logger.error("app exit: \(error)")
            }
            resetEmulate()
        }
    }

    public func forceStopEmulate() {
        forceStop = true
    }

    public func resetEmulate() {
        item = nil
        stop = false
        forceStop = false
    }

    private func startApp(_ name: String) async throws {
        do {
            emulate.state = .staring
            try await rpc.appStart(name, args: "RPC")
            try await waitForAppStartedEvent()
            return
        } catch let error as Error {
            if error == .application(.systemLocked) {
                emulate.state = .locked
            }
            throw error
        }
    }

    private func waitForAppStartedEvent() async throws {
        while emulate.state == .staring {
            try await Task.sleep(nanoseconds: 100 * 1_000_000)
        }
    }

    private func loadFile(_ path: Peripheral.Path) async throws {
        emulate.state = .loading
        try await rpc.appLoadFile(path)
        emulate.state = .loaded
    }

    private func startLoaded(_ item: ArchiveItem) async throws {
        guard emulate.state == .loaded else {
            return
        }
        if item.kind == .subghz {
            do {
                try await rpc.appButtonPress()
            } catch let error as Error where error == .application(.cmdError) {
                emulate.state = .restricted
                throw error
            }
            emulateStarted = .now
        }
        emulate.state = .emulating
        try await waitForMinimumDuration(for: item)
    }

    private func waitForMinimumDuration(for item: ArchiveItem) async throws {
        let stepMilliseconds = 10
        var delayMilliseconds = item.duration

        while delayMilliseconds > 0, !forceStop {
            delayMilliseconds -= stepMilliseconds
            try await Task.sleep(milliseconds: stepMilliseconds)
        }
    }

    private func stopLoaded(_ item: ArchiveItem) async throws {
        guard emulate.state == .emulating else {
            return
        }
        if item.kind == .subghz {
            try await rpc.appButtonRelease()
        }
    }

    private func exitApp() async throws {
        guard
            emulate.state != .closing,
            emulate.state != .closed,
            emulate.state != .locked
        else {
            return
        }
        emulate.state = .closing
        try await rpc.appExit()
    }

    // MARK: Analytics

    func recordEmulate() {
        analytics.appOpen(target: .keyEmulate)
    }
}

// MARK: Durations

extension ArchiveItem {
    public var duration:  Int {
        isRaw
            ? emulateRawMinimum
            : emulateMinimum
    }

    // Minimum for RAW SubGHz in ms
    var emulateRawMinimum: Int {
        let durationMicroseconds = properties
            .filter { $0.key == "RAW_Data" }
            .map { $0.value.split(separator: " ").compactMap { Int($0) } }
            .reduce(into: []) { $0.append(contentsOf: $1) }
            .map { abs($0) }
            .reduce(0, +)
        return durationMicroseconds / 1000
    }

    // Minimum for known SubGHz protocols (ms)
    var emulateMinimum: Int {
        500
    }
}

extension EmulateService {
    // Emulated since button pressed (ms)
    var emulateDuration: Int {
        Date().timeIntervalSince(emulateStarted).ms
    }

    func emulateDurationRemains(for item: ArchiveItem) -> Int {
        max(0, item.emulateMinimum - emulateDuration)
    }

    func emulateRawDurationRemains(for item: ArchiveItem) -> Int {
        max(0, item.emulateRawMinimum - emulateDuration)
    }
}

fileprivate extension Double {
    var ms: Int {
        Int(self * 1000)
    }
}
