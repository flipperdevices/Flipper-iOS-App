import Core
import Inject
import Logging
import Analytics
import Peripheral

import UIKit
import Combine
import Foundation

@MainActor
public class WidgetViewModel: ObservableObject {
    private let logger = Logger(label: "emulate-widget-vm")

    var container: UserDefaults? { .widget }
    @Published public var isExpanded = false

    @Inject var rpc: RPC
    @Inject var analytics: Analytics
    @Inject var storage: DeviceStorage
    @Inject var pairedDevice: PairedDevice
    private var disposeBag: DisposeBag = .init()

    @Published public var flipper: Flipper? {
        didSet { onFlipperChanged(oldValue) }
    }

    @Published var keys: [WidgetKey] = []
    @Published var emulatingIndex: Int?

    var item: ArchiveItem {
        guard let index = emulatingIndex else {
            return .none
        }
        let key = keys[index]
        let item = AppState.shared.archive.items.first {
            $0.name == key.name && $0.kind == key.kind
        }
        return item ?? .none
    }

    @Published var isEmulating = false
    @Published var isFileLoaded = false
    @Published var isFlipperAppStarted = false
    @Published var isFlipperAppCancellation = false
    @Published var isFlipperAppSystemLocked = false

    var forceStop = false
    var emulateStarted: Date = .now
    private var emulateTask: Task<Void, Swift.Error>?

    private var observer: NSKeyValueObservation?

    public init() {
        observer = container?
            .observe(
                \.widgetKeysData,
                options: [.initial, .new]
            ) { defaults, _ in
                self.keys = defaults.keys
            }

        pairedDevice.flipper
            .receive(on: DispatchQueue.main)
            .assign(to: \.flipper, on: self)
            .store(in: &disposeBag)

        rpc.onAppStateChanged { [weak self] state in
            guard let self = self else { return }
            Task { @MainActor in
                self.onAppStateChanged(state)
            }
        }
    }

    func connect() {
        pairedDevice.connect()
    }

    func disconnect() {
        pairedDevice.disconnect()
    }

    func onFlipperChanged(_ oldValue: Flipper?) {
        print(oldValue?.state, flipper?.state)
    }

    func state(at index: Int) -> WidgetKeyState {
        guard let emulatingIndex = emulatingIndex else {
            return .idle
        }
        return emulatingIndex == index ? .emulating : .disabled
    }

    func addKey() {
        #if os(iOS)
        UIApplication.shared.open(.widgetSettings)
        #endif
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

    func startApp(_ application: String) async throws {
        while !isFlipperAppCancellation {
            do {
                try await rpc.appStart(application, args: "RPC")
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

    func startEmulate(at index: Int) {
        guard !isEmulating else { return }
        isEmulating = true
        emulatingIndex = index
        emulateTask = Task {
            do {
                let item = keys[index]
                try await startApp(item.kind.application)
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
        guard let index = emulatingIndex else {
            return
        }
        let item = keys[index]

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

    func toggleEmulate(at index: Int) {
        isEmulating
            ? stopEmulate()
            : startEmulate(at: index)
    }

    func resetEmulate() {
        emulatingIndex = nil
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

enum WidgetKeyState {
    case idle
    case disabled
    case emulating
}

fileprivate extension Double {
    var ms: Int {
        Int(self * 1000)
    }
}
