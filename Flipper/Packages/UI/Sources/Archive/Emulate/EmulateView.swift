import Core
import SwiftUI

struct EmulateView: View {
    @EnvironmentObject var device: Device
    @EnvironmentObject var emulateService: EmulateService
    @Environment(\.dismiss) private var dismiss

    let item: ArchiveItem

    @State private var isEmulating = false
    @State private var showBubble = false
    @State private var showAppLocked = false
    @State private var showRestricted = false

    var showProgressButton: Bool {
        device.status == .connecting ||
        device.status == .synchronizing
    }

    var canEmulate: Bool {
        (device.status == .connected || device.status == .synchronized)
            && item.status == .synchronized
    }

    @State private var emulateDuration: Int = 0

    var body: some View {
        VStack(spacing: 4) {
            switch item.kind {
            case .nfc, .rfid, .ibutton:
                ZStack {
                    ConnectingButton()
                        .opacity(showProgressButton ? 1 : 0)
                    EmulateButton(
                        isEmulating: isEmulating,
                        onTapGesture: toggleEmulate,
                        onLongTapGesture: toggleEmulate
                    )
                    .opacity(showProgressButton ? 0 : 1)
                    .disabled(!canEmulate)
                }
                EmulateDescription(
                    item: item,
                    status: device.status,
                    isEmulating: isEmulating)
            case .subghz:
                ZStack {
                    ConnectingButton()
                        .opacity(showProgressButton ? 1 : 0)
                    SendButton(
                        isEmulating: isEmulating,
                        emulateDuration: item.duration,
                        onPressed: {
                            guard !isEmulating else {
                                forceStopEmulate()
                                return
                            }
                            startEmulate()
                        }, onReleased: {
                            stopEmulate()
                        }
                    )
                    .opacity(showProgressButton ? 0 : 1)
                    .disabled(!canEmulate)
                    Bubble("Hold to send continuously")
                        .offset(y: -34)
                        .opacity(showBubble ? 1 : 0)
                }
                EmulateDescription(
                    item: item,
                    status: device.status,
                    isEmulating: isEmulating)
            default:
                EmptyView()
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 18)
        .customAlert(isPresented: $showAppLocked) {
            FlipperBusyAlert(isPresented: $showAppLocked)
        }
        .customAlert(isPresented: $showRestricted) {
            TransmissionRestrictedAlert(isPresented: $showRestricted)
        }
        .onDisappear {
            forceStopEmulate()
        }
        .onChange(of: emulateService.state) { state in
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
        .onChange(of: device.status) { status in
            if status == .disconnected {
                resetEmulate()
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
        emulateService.startEmulate(item)
        showBubbleIfNeeded()
    }

    func stopEmulate() {
        guard isEmulating else { return }
        emulateService.stopEmulate()
    }

    func forceStopEmulate() {
        guard isEmulating else { return }
        emulateService.forceStopEmulate()
    }

    func toggleEmulate() {
        isEmulating
            ? stopEmulate()
            : startEmulate()
    }

    func resetEmulate() {
        isEmulating = false
        emulateService.resetEmulate()
    }
}
