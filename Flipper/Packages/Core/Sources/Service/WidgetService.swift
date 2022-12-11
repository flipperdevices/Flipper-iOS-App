import Inject
import Peripheral

import Logging
import Combine
import Foundation

@MainActor
public class WidgetService: ObservableObject {
    private let logger = Logger(label: "widget-service")

    let appState: AppState
    let emulateService: EmulateService

    var widget: WidgetModel {
        get { appState.widget }
        set { appState.widget = newValue }
    }

    public var isExpanded: Bool {
        get { widget.isExpanded }
        set { widget.isExpanded = newValue }
    }

    @Inject private var archive: Archive
    @Inject private var pairedDevice: PairedDevice
    @Inject private var storage: TodayWidgetStorage
    private var disposeBag = DisposeBag()

    public init(appState: AppState, emulateService: EmulateService) {
        self.appState = appState
        self.emulateService = emulateService
        subscribeToPublishers()
    }

    func subscribeToPublishers() {
        storage
            .didChange
            .sink { [weak self] in
                guard let self else { return }
                self.widget.keys = self.storage.keys
            }
            .store(in: &disposeBag)

        archive.items
            .receive(on: DispatchQueue.main)
            .sink { items in
                // remove deleted items
                self.widget.keys = self.widget.keys.filter(items.contains)
            }
            .store(in: &disposeBag)

        appState.$emulate
            .receive(on: DispatchQueue.main)
            .sink { [weak self] emulate in
                guard let self else { return }
                if emulate.state == .closed {
                    self.widget.keyToEmulate = nil
                }
                if emulate.state == .locked {
                    self.widget.keyToEmulate = nil
                    self.widget.state = .error(.appLocked)
                }
            }
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
            guard appState.flipper?.state != .connected else { return }
            self.logger.debug("widget connection time is out")
            Task { @MainActor in
                widget.state = .error(.cantConnect)
            }
        }
    }

    public func onSendPressed(for key: WidgetKey) {
        guard !widget.isEmulating else {
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
        guard widget.keyToEmulate == nil else {
            logger.critical("keyToEmulate should be nil")
            return
        }
        widget.keyToEmulate = key
        startEmulateOnConnect()
    }

    func startEmulateOnConnect() {
        guard
            appState.flipper?.state == .connected,
            let key = widget.keyToEmulate
        else {
            return
        }
        guard let item = item(for: key) else {
            logger.error("the key is not found")
            widget.state = .error(.notSynced)
            resetEmulate()
            return
        }
        guard item.status == .synchronized else {
            logger.error("the key is not synced")
            widget.state = .error(.notSynced)
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
        guard widget.isEmulating else { return }
        emulateService.stopEmulate()
    }

    func forceStopEmulate() {
        guard widget.isEmulating else { return }
        emulateService.forceStopEmulate()
    }

    func toggleEmulate(_ key: WidgetKey) {
        widget.isEmulating
            ? stopEmulate()
            : startEmulate(key)
    }

    func resetEmulate() {
        appState.widget.keyToEmulate = nil
        emulateService.resetEmulate()
    }
}

private extension Array where Element == ArchiveItem {
    func contains(widgetKey: WidgetKey) -> Bool {
        contains { $0.name == widgetKey.name && $0.kind == widgetKey.kind }
    }
}
