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
        self.remotes = item.getInfraredRemotes()
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

    var body: some View {
        switch state {
        case .disconnected:
            EmulateSupportView(text: "Flipper not connected")
        case .notSupported:
            EmulateSupportView(text: "Update firmware to use this feature")
        case .synchronizing:
            VStack(alignment: .center, spacing: 12.0) {
                ForEach(0 ..< remotes.count, id: \.self) { index in
                    ConnectingButton()
                }
            }
        case .canEmulate(let synchronized):
            VStack(alignment: .center, spacing: 12.0) {
                ForEach(0 ..< remotes.count, id: \.self) { index in
                    InfraredButton(
                        text: remotes[index],
                        isEmulating: currentEmulateIndex == index,
                        emulateDuration: item.duration,
                        onPressed: { processStartEmulate(index: index) },
                        onReleased: stopEmulate
                    )
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


    struct EmulateSupportView: View {
        let text: String

        var body: some View {
            VStack(spacing: 4) {
                ConnectingButton()
                HStack(spacing: 4) {
                    Image("WarningSmall")
                    Text(text)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.black20)
                }
            }
        }
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

extension ArchiveItem {
    func getInfraredRemotes() -> [String] {
        return self.properties
            .filter { $0.key == "name" }
            .map { $0.value }
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
