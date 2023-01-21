import Inject
import Peripheral

import Logging
import Combine
import Foundation

@MainActor
public class WidgetService: ObservableObject {
    let appState: AppState
    let emulateService: EmulateService

    @Published public var state: State = .idle
    @Published public var keys: [WidgetKey] = []
    @Published public var keyToEmulate: WidgetKey?

    @Published public var isExpanded = false

    public var isEmulating: Bool {
        state == .emulating
    }

    public var isError: Bool {
        switch state {
        case .error: return true
        default: return false
        }
    }

    public enum State: Equatable {
        case idle
        case loading
        case emulating
        case error(Error)

        public enum Error: Equatable {
            case appLocked
            case notSynced
            case cantConnect
            case bluetoothOff
        }
    }

    @Published public var flipper: Flipper?

    @Inject private var archive: Archive
    @Inject private var pairedDevice: PairedDevice
    @Inject private var storage: TodayWidgetStorage
    private var disposeBag = DisposeBag()

    public init(appState: AppState, emulateService: EmulateService) {
        self.appState = appState
        self.emulateService = emulateService
        self.keys = storage.keys
        subscribeToPublishers()
    }

    func subscribeToPublishers() {
        storage
            .didChange
            .sink { [weak self] in
                guard let self else { return }
                self.keys = self.storage.keys
            }
            .store(in: &disposeBag)

        archive.items
            .receive(on: DispatchQueue.main)
            .sink { items in
                // remove deleted items
                self.keys = self.keys.filter(items.contains)
            }
            .store(in: &disposeBag)

        emulateService.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self else { return }
                if state == .closed {
                    self.keyToEmulate = nil
                }
                if state == .locked {
                    self.keyToEmulate = nil
                    self.state = .error(.appLocked)
                }
            }
            .store(in: &disposeBag)

        pairedDevice.flipper
            .receive(on: DispatchQueue.main)
            .assign(to: \.flipper, on: self)
            .store(in: &disposeBag)
    }

    public func add(_ key: ArchiveItem) {
        storage.keys.append(.init(name: key.name, kind: key.kind))
    }

    public func delete(at index: Int) {
        storage.keys.remove(at: index)
    }

    func connect() {
        pairedDevice.connect()
        setupTimeoutTimer()
    }

    func disconnect() {
        pairedDevice.disconnect()
    }

    func onFlipperStatusChanged(_ oldValue: FlipperState?) {
        guard appState.status == .connected else {
            connect()
            return
        }
        if oldValue != .connected {
            startEmulateOnConnect()
        }
    }

    private var timeoutTask: Task<Void, Swift.Error>?
    private var timeoutNanoseconds: UInt64 { 3 * 1_000 * 1_000_000 }

    func setupTimeoutTimer() {
        if let current = timeoutTask {
            current.cancel()
        }
        timeoutTask = Task {
            try await Task.sleep(nanoseconds: timeoutNanoseconds)
            guard flipper?.state != .connected else { return }
            logger.debug("widget connection time is out")
            Task { @MainActor in
                state = .error(.cantConnect)
            }
        }
    }

    public func onSendPressed(for key: WidgetKey) {
        guard !isEmulating else {
            emulateService.forceStopEmulate()
            return
        }
        startEmulate(key)
    }

    public func onSendReleased(for key: WidgetKey) {
        stopEmulate()
    }

    public func onEmulateTapped(for key: WidgetKey) {
        toggleEmulate(key)
    }

    func startEmulate(_ key: WidgetKey) {
        guard keyToEmulate == nil else {
            logger.critical("keyToEmulate should be nil")
            return
        }
        keyToEmulate = key
        startEmulateOnConnect()
    }

    func startEmulateOnConnect() {
        guard
            flipper?.state == .connected,
            let key = keyToEmulate
        else {
            return
        }
        guard let item = item(for: key) else {
            logger.error("the key is not found")
            state = .error(.notSynced)
            resetEmulate()
            return
        }
        guard item.status == .synchronized else {
            logger.error("the key is not synced")
            state = .error(.notSynced)
            resetEmulate()
            return
        }
        emulateService.startEmulate(item)
    }

    func item(for key: WidgetKey) -> ArchiveItem? {
        nil
        // TODO: (refactoring)
        // archive.items.first {
        //     $0.name == key.name && $0.kind == key.kind
        // }
    }

    public func stopEmulate() {
        guard isEmulating else { return }
        emulateService.stopEmulate()
    }

    func forceStopEmulate() {
        guard isEmulating else { return }
        emulateService.forceStopEmulate()
    }

    func toggleEmulate(_ key: WidgetKey) {
        isEmulating
            ? stopEmulate()
            : startEmulate(key)
    }

    func resetEmulate() {
        keyToEmulate = nil
        emulateService.resetEmulate()
    }
}

private extension Array where Element == ArchiveItem {
    func contains(widgetKey: WidgetKey) -> Bool {
        contains { $0.name == widgetKey.name && $0.kind == widgetKey.kind }
    }
}
