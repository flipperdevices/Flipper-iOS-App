import Core
import SwiftUI

struct InfraredLayoutView: View {
    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject private var emulate: Emulate
    @EnvironmentObject private var device: Device
    @EnvironmentObject private var infraredModel: InfraredModel

    let onShare: () -> Void
    let onDelete: () -> Void

    let layout: InfraredLayout
    @Binding var current: ArchiveItem
    @Binding var isEditing: Bool

    @State private var isFlipperBusyAlertPresented: Bool = false
    @State private var showRemoteControl = false
    @State private var showHowToUse: Bool = false
    @State private var showFlipperNotSupported: Bool = false

    var layoutState: InfraredLayoutState {
        if device.status == .disconnected {
            return .disabled
        }

        if device.status == .connecting || device.status == .synchronizing {
            return .syncing
        }

        if let flipper = device.flipper, !flipper.hasInfraredEmulateSupport {
            return .notSupported
        }

        if current.status != .synchronized {
            return .disabled
        }

        return emulate.inProgress ? .emulating : .default
    }

    var body: some View {
        VStack(spacing: 0) {
            // TODO: wait design for many-pages
            if let page = layout.pages.first {
                InfraredPageLayoutView(buttons: page.buttons)
                    .environment(\.layoutState, layoutState)
                    .environment(\.emulateAction, emulate)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            LeadingToolbarItems {
                BackButton {
                    dismiss()
                }
            }
            PrincipalToolbarItems {
                InfraredLayoutTitle(
                    keyName: current.name.value,
                    state: layoutState
                )
            }
            TrailingToolbarItems {
                InfraredLayoutMenuButton(
                    item: $current,
                    onShare: onShare,
                    onDelete: onDelete,
                    onEdit: { isEditing = true },
                    onHowTo: { showHowToUse = true }
                )
            }
        }
        .alert(isPresented: $isFlipperBusyAlertPresented) {
            FlipperIsBusyAlert(isPresented: $isFlipperBusyAlertPresented) {
                showRemoteControl = true
            }
        }
        .alert(isPresented: $showHowToUse) {
            InfraredHowToUseRemoteDialog(isPresented: $showHowToUse)
        }
        .sheet(isPresented: $showRemoteControl) {
            RemoteControlView()
                .environmentObject(device)
        }
        .alert(isPresented: $showFlipperNotSupported) {
            NotSupportedFeatureAlert(
                isPresented: $showFlipperNotSupported)
        }
        .onReceive(device.$flipper) { flipper in
            guard
                let flipper = flipper,
                flipper.state == .connected
            else { return }

            if !flipper.hasInfraredEmulateSupport {
                self.showFlipperNotSupported = true
            }
        }
        .onChange(of: emulate.state) { state in
            if state == .locked {
                self.isFlipperBusyAlertPresented = true
            }
            if state == .staring || state == .started || state == .closed {
                feedback(style: .soft)
            }
        }
    }

    private func emulate(_ keyID: InfraredKeyID) {
        guard
            let index = current.properties.getIndex(by: keyID)
        else { return }

        emulate.startEmulate(current, config: .byIndex(index))
        emulate.stopEmulate()
    }
}
