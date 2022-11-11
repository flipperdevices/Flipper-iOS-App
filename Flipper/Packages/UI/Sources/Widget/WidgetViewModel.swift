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

    var emulate: Emulate = .init()

    @Inject private var archive: Archive
    @Inject private var storage: TodayWidgetStorage
    @Inject private var analytics: Analytics
    @Inject private var pairedDevice: PairedDevice
    private var disposeBag: DisposeBag = .init()

    @Published public var flipper: Flipper? {
        didSet { onFlipperChanged(oldValue) }
    }

    var items: [ArchiveItem] = []
    @Published public private(set) var keys: [WidgetKey] = []
    @Published var isEmulating = false
    @Published var showAppLocked = false

    var emulatingIndex: Int? {
        didSet {
            isEmulating = emulatingIndex != nil
        }
    }

    private var observer: NSKeyValueObservation?

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
            .assign(to: \.flipper, on: self)
            .store(in: &disposeBag)

        emulate.onStateChanged = { [weak self] state in
            guard let self = self else { return }
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

    func startEmulate(at index: Int) {
        guard !isEmulating else { return }
        guard let item = item(for: keys[index]) else {
            print("key not found")
            return
        }
        emulatingIndex = index
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
