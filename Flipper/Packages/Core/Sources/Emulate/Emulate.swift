import Inject
import Analytics
import Peripheral
import Combine
import Logging
import Foundation

public class Emulate: ObservableObject {
    private let logger = Logger(label: "emulate")

    @Inject var rpc: RPC

    var item: ArchiveItem?
    public var onStateChanged: (ApplicationState) -> Void = { _ in }

    @Published public var applicationState: ApplicationState = .closed {
        didSet {
            onStateChanged(applicationState)
            if applicationState == .closed {
                resetEmulate()
            }
        }
    }

    public enum ApplicationState: Equatable {
        case staring
        case started
        case loading
        case loaded
        case emulating
        case closing
        case closed
        case locked
        case restricted
    }

    private var stop = false
    private var forceStop = false
    private var emulateTask: Task<Void, Swift.Error>?
    private var emulateStarted: Date = .now

    public init() {
        rpc.onAppStateChanged { [weak self] state in
            guard let self = self else { return }
            Task { @MainActor in
                self.onFlipperAppStateChanged(state)
            }
        }
    }

    func onFlipperAppStateChanged(_ state: Message.AppState) {
        switch state {
        case .started: self.applicationState = .started
        case .closed: self.applicationState = .closed
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
            applicationState = .staring
            try await rpc.appStart(name, args: "RPC")
            try await waitForAppStartedEvent()
            return
        } catch let error as Error {
            if error == .application(.systemLocked) {
                applicationState = .locked
            }
            throw error
        }
    }

    private func waitForAppStartedEvent() async throws {
        while applicationState == .staring {
            try await Task.sleep(nanoseconds: 100 * 1_000_000)
        }
    }

    private func loadFile(_ path: Peripheral.Path) async throws {
        applicationState = .loading
        try await rpc.appLoadFile(path)
        applicationState = .loaded
    }

    private func startLoaded(_ item: ArchiveItem) async throws {
        guard applicationState == .loaded else {
            return
        }
        if item.kind == .subghz {
            do {
                try await rpc.appButtonPress()
            } catch let error as Error where error == .application(.cmdError) {
                applicationState = .restricted
                throw error
            }
            emulateStarted = .now
        }
        applicationState = .emulating
        try await waitForMinimumDuration(for: item)
    }

    private func waitForMinimumDuration(for item: ArchiveItem) async throws {
        let stepMilliseconds = 10
        var delayMilliseconds = duration(for: item)

        while delayMilliseconds > 0, !forceStop {
            delayMilliseconds -= stepMilliseconds
            try await Task.sleep(milliseconds: stepMilliseconds)
        }
    }

    private func stopLoaded(_ item: ArchiveItem) async throws {
        guard applicationState == .emulating else {
            return
        }
        if item.kind == .subghz {
            try await rpc.appButtonRelease()
        }
    }

    private func exitApp() async throws {
        guard
            applicationState != .closing,
            applicationState != .closed,
            applicationState != .locked
        else {
            return
        }
        applicationState = .closing
        try await rpc.appExit()
    }
}

// MARK: Durations

extension Emulate {
    public func duration(for item: ArchiveItem) -> Int {
        item.isRaw
            ? emulateRawMinimum(for: item)
            : emulateMinimum
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
    func emulateRawMinimum(for item: ArchiveItem) -> Int {
        let durationMicroseconds = item.properties
            .filter { $0.key == "RAW_Data" }
            .map { $0.value.split(separator: " ").compactMap { Int($0) } }
            .reduce(into: []) { $0.append(contentsOf: $1) }
            .map { abs($0) }
            .reduce(0, +)
        return durationMicroseconds / 1000
    }

    func emulateRawDurationRemains(for item: ArchiveItem) -> Int {
        max(0, emulateRawMinimum(for: item) - emulateDuration)
    }
}

fileprivate extension Double {
    var ms: Int {
        Int(self * 1000)
    }
}
