import Peripheral

import Combine
import Foundation

@MainActor
public class TodayWidget: ObservableObject {
    @Published public var isExpanded: Bool = false
    @Published public var keys: [WidgetKey] = []

    @Published public var keyToEmulate: WidgetKey?
    @Published public var error: Error?

    var bluetoothStatus: BluetoothStatus = .unknown {
        didSet {
            onBluetoothStatusChanged(oldValue)
        }
    }

    var flipperStatus: FlipperState = .disconnected {
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
    private var emulate: Emulate
    private var archive: Archive
    private var central: Central
    private var device: PairedDevice

    public init(
        widgetStorage: TodayWidgetKeysStorage,
        emulate: Emulate,
        archive: Archive,
        central: Central,
        device: PairedDevice
    ) {
        self.widgetStorage = widgetStorage
        self.emulate = emulate
        self.archive = archive
        self.central = central
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

        emulate.$state
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

        central.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self else { return }
                self.bluetoothStatus = state
            }
            .store(in: &cancellables)

        device.flipper
            .receive(on: DispatchQueue.main)
            .map { $0?.state ?? .disconnected }
            .sink { [weak self] state in
                guard let self else { return }
                self.flipperStatus = state
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
        guard bluetoothStatus == .poweredOn else {
            central.kick()
            return
        }
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
            if flipperStatus != .connected {
                logger.debug("widget connection timeout")
                Task { @MainActor in
                    error = .cantConnect
                    resetEmulate()
                    connect()
                }
            }
        }
    }

    func onBluetoothStatusChanged(_ oldValue: BluetoothStatus) {
        switch bluetoothStatus {
        case .poweredOn:
            if error == .bluetoothOff {
                error = nil
            }
            connect()
        case .poweredOff, .unauthorized:
            error = .bluetoothOff
        default:
            break
        }
    }

    func onFlipperStatusChanged(_ oldValue: FlipperState?) {
        if flipperStatus == .connected, oldValue != .connected {
            timeoutTask?.cancel()
            startEmulateOrConnect()
        }
        if flipperStatus == .disconnected {
            keyToEmulate = nil
        }
    }

    public func disconnect() {
        stopEmulate()
        device.disconnect()
    }

    public func onSendPressed(for key: WidgetKey) {
        keyToEmulate == nil
            ? startEmulate(key)
            : emulate.forceStopEmulate()
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
        startEmulateOrConnect()
    }

    func startEmulateOrConnect() {
        guard flipperStatus == .connected else {
            connect()
            return
        }
        guard let key = keyToEmulate else {
            return
        }
        guard let item = item(for: key), item.status == .synchronized else {
            logger.error("the key is not synced")
            error = .notSynced
            resetEmulate()
            return
        }
        emulate.startEmulate(item)
    }

    private func item(for key: WidgetKey) -> ArchiveItem? {
        archive.get(.init(path: key.path))
    }

    public func stopEmulate() {
        emulate.stopEmulate()
    }

    func forceStopEmulate() {
        emulate.forceStopEmulate()
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
