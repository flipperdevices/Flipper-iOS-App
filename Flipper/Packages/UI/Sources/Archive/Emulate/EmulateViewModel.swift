import Core
import Inject
import Analytics
import Peripheral
import SwiftUI
import Logging

@MainActor
class EmulateViewModel: ObservableObject {
    private let logger = Logger(label: "emulate-vm")

    @Inject var analytics: Analytics
    var emulate: Emulate = .init()

    @Published var item: ArchiveItem
    @Published var deviceStatus: DeviceStatus = .disconnected
    @Published var isEmulating = false
    @Published var showBubble = false
    @Published var showAppLocked = false
    @Published var showRestricted = false

    var showProgressButton: Bool {
        deviceStatus == .connecting ||
        deviceStatus == .synchronizing
    }

    var canEmulate: Bool {
        (deviceStatus == .connected || deviceStatus == .synchronized)
            && item.status == .synchronized
    }

    var emulateDuration: Int

    @Inject private var appState: AppState
    var disposeBag = DisposeBag()

    init(item: ArchiveItem) {
        self.item = item
        self.emulateDuration = emulate.duration(for: item)

        appState.$status
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self = self else { return }
                self.deviceStatus = $0
                if self.deviceStatus == .disconnected {
                    self.resetEmulate()
                }
            }
            .store(in: &disposeBag)

        emulate.onStateChanged = { [weak self] state in
            guard let self = self else { return }
            Task { @MainActor in
                if state == .closed {
                    self.isEmulating = false
                }
                if state == .locked {
                    self.isEmulating = false
                    self.showAppLocked = true
                }
                if state == .restricted {
                    self.isEmulating = false
                    self.showRestricted = true
                }
                if state == .staring || state == .started || state == .closed {
                    feedback(style: .soft)
                }
            }
        }
    }

    func showBubbleIfNeeded() {
        guard !showBubble else { return }
        Task {
            withAnimation(.linear(duration: 0.3)) {
                showBubble = true
            }
            try await Task.sleep(seconds: 2)
            withAnimation(.linear(duration: 1)) {
                showBubble = false
            }
        }
    }

    func startEmulate() {
        guard !isEmulating else { return }
        isEmulating = true
        emulate.startEmulate(item)
        showBubbleIfNeeded()
        recordEmulate()
    }

    func stopEmulate() {
        guard isEmulating else { return }
        emulate.stopEmulate()
    }

    func forceStopEmulate() {
        guard isEmulating else { return }
        emulate.forceStopEmulate()
    }

    func toggleEmulate() {
        isEmulating
            ? stopEmulate()
            : startEmulate()
    }

    func resetEmulate() {
        isEmulating = false
        emulate.resetEmulate()
    }

    // Analytics

    func recordEmulate() {
        analytics.appOpen(target: .keyEmulate)
    }
}
