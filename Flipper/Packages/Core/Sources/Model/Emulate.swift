import Peripheral

import Combine
import Foundation

@MainActor
public class Emulate: ObservableObject {
    @Published public var state: State = .closed

    public enum State: Equatable {
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

    public enum Config {
        case `default`
        case subGhz
        case infrared(index: Int)
    }

    var item: ArchiveItem?

    private var stop = false
    private var forceStop = false
    private var emulateTask: Task<Void, Swift.Error>?

    private var application: ApplicationAPI

    public init(application: ApplicationAPI) {
        self.application = application
        subscribeToPublishers()
    }

    func subscribeToPublishers() {
        Task { @MainActor in
            while !Task.isCancelled {
                for await state in await application.state {
                    onFlipperAppStateChanged(state)
                }
            }
        }
    }

    func onFlipperAppStateChanged(_ newValue: IncomingMessage.AppState) {
        switch newValue {
        case .started:
            self.state = .started
        case .closed:
            self.state = .closed
            resetEmulate()
        case .unknown:
            logger.critical("unknown app state")
        }
    }

    public func startEmulate(
        _ item: ArchiveItem,
        _ config: Config
    ) {
        guard self.item == nil else {
            return
        }
        self.item = item
        emulateTask = Task {
            do {
                try await startApp(item.kind.application)
                try await loadFile(item.path)
                try await startLoaded(item, config: config)
                recordEmulate()
            } catch {
                logger.error("emilating key: \(error)")
                resetEmulate()
            }
            emulateTask = nil
        }
    }

    public func emulateSingle(_ item: ArchiveItem, index: Int) {
        guard self.item == nil else {
            return
        }
        self.item = item
        emulateTask = Task {
            do {
                try await startApp(item.kind.application)
                try await loadFile(item.path)
                try await sendLoaded(index: index)
                recordEmulate()
                try await waitForMinimumDuration(for: item)
            } catch {
                logger.error("emulating key: \(error)")
            }
            do {
                try await exitApp()
                try await waitForAppClosedEvent()
            } catch {
                logger.error("app exit: \(error)")
            }
            resetEmulate()
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

    private func resetEmulate() {
        item = nil
        stop = false
        forceStop = false
    }

    private func startApp(_ name: String) async throws {
        do {
            state = .staring
            try await application.start(name, args: "RPC")
            try await waitForAppStartedEvent()
            return
        } catch let error as Error {
            if error == .application(.systemLocked) {
                state = .locked
            }
            throw error
        }
    }

    private func waitForAppStartedEvent() async throws {
        while state == .staring {
            try await Task.sleep(nanoseconds: 100 * 1_000_000)
        }
    }

    private func waitForAppClosedEvent() async throws {
        while state == .closing {
            try await Task.sleep(nanoseconds: 100 * 1_000_000)
        }
    }

    private func loadFile(_ path: Peripheral.Path) async throws {
        state = .loading
        try await application.loadFile(path)
        state = .loaded
    }

    private func startLoaded(
        _ item: ArchiveItem,
        config: Config
    ) async throws {
        guard state == .loaded else {
            return
        }

        switch config {
        case .infrared(let index):
            try await application.buttonPress(index: index)
            try await waitForMinimumDuration(for: item)
        case .subGhz:
            do {
                try await application.buttonPress()
                try await waitForMinimumDuration(for: item)
            } catch let error as Error where error == .application(.cmdError) {
                state = .restricted
                throw error
            }
        case .default: ()
        }

        state = .emulating
    }

    private func waitForMinimumDuration(for item: ArchiveItem) async throws {
        let stepMilliseconds = 10
        var delayMilliseconds = item.duration

        while delayMilliseconds > 0, !forceStop {
            delayMilliseconds -= stepMilliseconds
            try await Task.sleep(milliseconds: stepMilliseconds)
        }
    }

    private func sendLoaded(index: Int) async throws {
        guard state == .loaded else {
            return
        }
        try await application.buttonPressRelease(index: index)
        state = .emulating
    }

    private func stopLoaded(_ item: ArchiveItem) async throws {
        guard state == .emulating else {
            return
        }
        if item.kind == .subghz || item.kind == .infrared {
            try await application.buttonRelease()
        }
    }

    private func exitApp() async throws {
        guard
            state != .closing,
            state != .closed,
            state != .locked
        else {
            return
        }
        state = .closing
        try await application.exit()
    }

    // MARK: Analytics

    func recordEmulate() {
        analytics.appOpen(target: .keyEmulate)
    }
}

// MARK: Durations

extension ArchiveItem {
    public var duration: Int {
        switch kind {
        case .subghz: isRaw ? emulateRawMinimum : emulateMinimum
        case .infrared: emulateMinimum
        default: 0
        }
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

    public var defaultConfig: Emulate.Config {
        switch kind {
        case .subghz: .subGhz
        case .infrared: .infrared(index: 0)
        default: .default
        }
    }
}

public extension Emulate {
    var inProgress: Bool {
        self.state != .closed &&
        self.state != .locked &&
        self.state != .restricted
    }
}
