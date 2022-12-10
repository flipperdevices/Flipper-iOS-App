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

    @Published public var isExpanded = false
    public var isError: Bool {
        showAppLocked || showNotSynced || showCantConnect
    }

    var emulate: EmulateService = .init()

    @Inject private var archive: Archive
    @Inject private var storage: TodayWidgetStorage
    @Inject private var connector: BluetoothConnector
    @Inject private var analytics: Analytics
    @Inject private var pairedDevice: PairedDevice
    private var disposeBag: DisposeBag = .init()

    @Published public var flipperState: FlipperState? {
        didSet {
            if oldValue != flipperState {
                onFlipperStatusChanged(oldValue)
            }
        }
    }

    var items: [ArchiveItem] = []
    @Published public private(set) var keys: [WidgetKey] = []
    @Published var isEmulating = false
    @Published var showAppLocked = false
    @Published var showNotSynced = false
    @Published var showBTTurnedOff = false
    @Published var showCantConnect = false {
        didSet {
            if showCantConnect == false {
                setupTimeoutTimer()
            }
        }
    }

    var emulatingIndex: Int? {
        didSet {
            isEmulating = emulatingIndex != nil
        }
    }

    private var observer: NSKeyValueObservation?
    var timeoutTask: Task<Void, Swift.Error>?

    var isBTTurnedOff = false {
        didSet { showBTTurnedOff = isBTTurnedOff }
    }

    public init() {
        loadKeys()

        storage.didChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.loadKeys()
            }
            .store(in: &disposeBag)

        archive.items
            .receive(on: DispatchQueue.main)
            .assign(to: \.items, on: self)
            .store(in: &disposeBag)

        pairedDevice.flipper
            .receive(on: DispatchQueue.main)
            .map(\.?.state)
            .assign(to: \.flipperState, on: self)
            .store(in: &disposeBag)

        connector.status
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self else { return }
                self.isBTTurnedOff = status == .notReady(.poweredOff)
            }
            .store(in: &disposeBag)

        emulate.$applicationState
            .sink { [weak self] state in
                guard let self else { return }
                Task { @MainActor in
                    if state == .closed {
                        self.emulatingIndex = nil
                    }
                    if state == .locked {
                        self.emulatingIndex = nil
                        self.showAppLocked = true
                    }
                    if state == .staring || state == .started || state == .closed {
                        feedback(style: .soft)
                    }
                }
            }
    }

    func loadKeys() {
        keys = storage.keys
    }

    func connect() {
        pairedDevice.connect()
        setupTimeoutTimer()
    }

    func disconnect() {
        pairedDevice.disconnect()
    }

    func onFlipperStatusChanged(_ oldValue: FlipperState?) {
        guard flipperState == .connected else {
            connect()
            return
        }
        if oldValue != .connected {
            startEmulateOnConnect()
        }
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

    func startEmulate(at index: Int) {
        guard !isBTTurnedOff else {
            showBTTurnedOff = true
            return
        }
        guard emulatingIndex == nil else {
            logger.critical("emulate item index is nil")
            return
        }
        emulatingIndex = index
        startEmulateOnConnect()
    }

    func startEmulateOnConnect() {
        guard flipperState == .connected, let index = emulatingIndex else {
            return
        }
        guard let item = item(for: keys[index]) else {
            logger.error("the key is not found")
            resetEmulate()
            return
        }
        guard item.status == .synchronized else {
            logger.error("the key is not synced")
            showNotSynced = true
            resetEmulate()
            return
        }
        emulate.startEmulate(item)
        recordEmulate()
    }

    func item(for key: WidgetKey) -> ArchiveItem? {
        items.first {
            $0.name == key.name && $0.kind == key.kind
        }
    }

    func stopEmulate() {
        guard isEmulating else { return }
        emulate.stopEmulate()
    }

    func forceStopEmulate() {
        guard isEmulating else { return }
        emulate.forceStopEmulate()
    }

    func toggleEmulate(at index: Int) {
        isEmulating
            ? stopEmulate()
            : startEmulate(at: index)
    }

    func resetEmulate() {
        emulatingIndex = nil
        emulate.resetEmulate()
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

extension WidgetViewModel {
    var timeoutNanoseconds: UInt64 { 3 * 1_000 * 1_000_000 }

    func setupTimeoutTimer() {
        if let current = timeoutTask {
            current.cancel()
        }
        timeoutTask = Task {
            try await Task.sleep(nanoseconds: timeoutNanoseconds)
            guard self.flipperState != .connected else { return }
            self.logger.debug("widget connection time is out")
            Task { @MainActor in
                self.showCantConnect = true
            }
        }
    }
}
