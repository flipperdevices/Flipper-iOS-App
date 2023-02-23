import Core
import Peripheral

import Combine
import Foundation

@MainActor
public class TodayWidget: ObservableObject {
    @Published public var isExpanded: Bool = false
    @Published public var keys: [WidgetKey] = []

    @Published public var keyToEmulate: WidgetKey?
    @Published public var error: Error?

    var flipperState: FlipperState = .disconnected {
        didSet {
            onFlipperStatusChanged(oldValue)
        }
    }

    public enum Error: Equatable {
        case appLocked
        case notSynced
        case cantConnect
        case bluetoothOff
    }

    private var cancellables: [AnyCancellable] = []

    private var widgetStorage: TodayWidgetKeysStorage
    private var emulateService: EmulateService
    private var archive: Archive
    private var device: PairedDevice

    public init(
        widgetStorage: TodayWidgetKeysStorage,
        emulateService: EmulateService,
        archive: Archive,
        device: PairedDevice
    ) {
        self.widgetStorage = widgetStorage
        self.emulateService = emulateService
        self.archive = archive
        self.device = device
        subscribeToPublisher()
        loadKeys()
    }

    func subscribeToPublisher() {
        widgetStorage.didChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self else { return }
                self.loadKeys()
            }
            .store(in: &cancellables)

        emulateService.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self else { return }
                if state == .closed {
                    self.keyToEmulate = nil
                }
                if state == .locked {
                    self.keyToEmulate = nil
                    self.error = .appLocked
                }
            }
            .store(in: &cancellables)

        device.flipper
            .receive(on: DispatchQueue.main)
            .map { $0?.state ?? .disconnected }
            .sink { [weak self] state in
                self?.flipperState = state
            }
            .store(in: &cancellables)
    }

    private func loadKeys() {
        Task {
            keys = try await widgetStorage.read()
        }
    }

    public func add(_ key: WidgetKey) {
        Task {
            keys.append(key)
            try await widgetStorage.write(keys)
        }
    }

    public func delete(_ key: WidgetKey) {
        Task {
            keys = keys.filter { $0 != key }
            try await widgetStorage.write(keys)
        }
    }

    public func connect() {
        device.connect()
        setupConnectionTimer(timeout: 5)
    }

    private var timeoutTask: Task<Void, Swift.Error>?

    func setupConnectionTimer(timeout: TimeInterval) {
        if let current = timeoutTask {
            current.cancel()
        }
        timeoutTask = Task {
            try await Task.sleep(milliseconds: .init(timeout * 1_000))
            if flipperState != .connected {
                logger.debug("widget connection timeout")
                Task { @MainActor in
                    error = .cantConnect
                    resetEmulate()
                    connect()
                }
            }
        }
    }

    func onFlipperStatusChanged(_ oldValue: FlipperState?) {
        if flipperState == .connected, oldValue != .connected {
            timeoutTask?.cancel()
            startEmulateOnConnect()
        }
    }

    public func disconnect() {
        stopEmulate()
        device.disconnect()
    }

    public func onSendPressed(for key: WidgetKey) {
        keyToEmulate == nil
            ? startEmulate(key)
            : emulateService.forceStopEmulate()
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
            flipperState == .connected,
            let key = keyToEmulate
        else {
            return
        }
        guard let item = item(for: key), item.status == .synchronized else {
            logger.error("the key is not synced")
            error = .notSynced
            resetEmulate()
            return
        }
        emulateService.startEmulate(item)
    }

    private func item(for key: WidgetKey) -> ArchiveItem? {
        archive.get(.init(path: key.path))
    }

    public func stopEmulate() {
        emulateService.stopEmulate()
    }

    func forceStopEmulate() {
        emulateService.forceStopEmulate()
    }

    func toggleEmulate(_ key: WidgetKey) {
        keyToEmulate == nil
            ? startEmulate(key)
            : stopEmulate()
    }

    func resetEmulate() {
        keyToEmulate = nil
    }

    public func closeError() {
        error = nil
    }
}

private extension Array where Element == ArchiveItem {
    func contains(widgetKey: WidgetKey) -> Bool {
        contains { $0.name == widgetKey.name && $0.kind == widgetKey.kind }
    }
}
