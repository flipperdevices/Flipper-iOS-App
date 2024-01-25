import Core
import SwiftUI

struct InfraredEmulateView: View {
    @EnvironmentObject var device: Device
    @EnvironmentObject var emulate: Emulate

    @State var currentEmulateIndex: Int?

    let item: ArchiveItem
    let remotes: [String]

    init(item: ArchiveItem) {
        self.item = item
        self.remotes = item.getInfraredRemoteNames
    }

    enum InfraredEmulateStatus {
        case disconnected
        case synchronizing
        case notSupported
        case canEmulate(Bool)
    }

    var state: InfraredEmulateStatus {
        if device.status == .disconnected {
            return .disconnected
        }

        if device.status == .connecting || device.status == .synchronizing {
            return .synchronizing
        }

        if let flipper = device.flipper, !flipper.hasInfraredEmulateSupport {
            return .notSupported
        }
        return .canEmulate(item.status == .synchronized)
    }

    var isEmptyRemotes: Bool {
        remotes.isEmpty
    }

    var body: some View {
        switch state {
        case .disconnected:
            notSupportEmulateView()
            EmulateSupportView(text: "Flipper not connected")
                .padding(.bottom, isEmptyRemotes ? 0 : 4)
        case .notSupported:
            notSupportEmulateView()
            EmulateSupportView(text: "Update firmware to use this feature")
                .padding(.bottom, isEmptyRemotes ? 0 : 4)
        case .synchronizing:
            if isEmptyRemotes {
                ConnectingButton()
            } else {
                VStack(alignment: .center, spacing: 12.0) {
                    ForEach(0 ..< remotes.count, id: \.self) { _ in
                        ConnectingButton()
                    }
                }
            }
        case .canEmulate(let synchronized):
            if isEmptyRemotes {
                EmulateEmptyView()
            } else {
                VStack(alignment: .center, spacing: 12.0) {
                    ForEach(0 ..< remotes.count, id: \.self) { index in
                        infraredRemoteView(index: index)
                            .disabled(!synchronized)
                    }
                }
                .onChange(of: emulate.state) { state in
                    if state == .closed || state == .locked {
                        currentEmulateIndex = nil
                    }
                }
                .onChange(of: device.status) { status in
                    if status == .disconnected {
                        currentEmulateIndex = nil
                    }
                }
            }
        }
    }

    struct EmulateSupportView: View {
        let text: String

        var body: some View {
            HStack(spacing: 4) {
                Image("WarningSmall")
                Text(text)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.black20)
            }
            .frame(maxWidth: .infinity)
        }
    }

    struct EmulateEmptyView: View {
        var body: some View {
            Text("No buttons saved for this remote yet.\n" +
                 "Use your Flipper Zero to add some."
            )
            .multilineTextAlignment(.center)
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(.black20)
            .frame(maxWidth: .infinity)
        }
    }

    @ViewBuilder private func infraredRemoteView(index: Int) -> some View {
        InfraredButton(
            text: remotes[index],
            isEmulating: currentEmulateIndex == index,
            emulateDuration: item.duration,
            onPressed: { processStartEmulate(index: index) },
            onReleased: stopEmulate
        )
    }

    @ViewBuilder private func notSupportEmulateView() -> some View {
        VStack(alignment: .center, spacing: 12.0) {
            if remotes.count > 3 {
                infraredRemoteView(index: 0)
                infraredRemoteView(index: 1)
                HStack(alignment: .center) {
                    Text(remotes[2])
                        .font(.born2bSportyV2(size: 23))
                }
                .frame(height: 48)
                .frame(maxWidth: .infinity)
                .foregroundColor(.white)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.emulateDisabled, .clear]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                ForEach(0 ..< remotes.count, id: \.self) { index in
                    infraredRemoteView(index: index)
                }
            }
        }
        .disabled(true)
    }

    func processStartEmulate(index: Int) {
        if currentEmulateIndex == index {
            forceStopEmulate()
        } else {
            startEmulate(index: index)
        }
    }

    func startEmulate(index: Int) {
        currentEmulateIndex = index
        emulate.startEmulate(item, config: .byIndex(index))
    }

    func stopEmulate() {
        guard currentEmulateIndex != nil else { return }
        emulate.stopEmulate()
    }

    func forceStopEmulate() {
        guard currentEmulateIndex != nil else { return }
        emulate.forceStopEmulate()
    }
}

extension Flipper {
    var hasInfraredEmulateSupport: Bool {
        guard
            let protobuf = information?.protobufRevision,
            protobuf >= .v0_21
        else {
            return false
        }
        return true
    }
}
