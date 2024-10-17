import Core
import SwiftUI

struct InfraredLibraryCard: View {
    var body: some View {
        HubCard(
            icon: "infrared",
            title: "Infrared",
            image: "InfraredRemoteLibrary",
            subtitle: "Remotes Library",
            description:
                "Find remotes for your devices from a " +
                "wide range of brands and models"
        ) {
            Badge()
        }
    }

    struct Badge: View {
        @Environment(\.colorScheme) var colorScheme

        private var color: Color {
            switch colorScheme {
            case .light: return .black40
            default: return .black30
            }
        }

        var body: some View {
            Text("Beta")
                .font(.system(size: 12))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .foregroundColor(color)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(color, lineWidth: 1)
                )
                .padding(.trailing, 4)
        }
    }
}

struct InfraredLibraryCardButton: View {
    let onTap: () -> Void

    @EnvironmentObject var device: Device
    @EnvironmentObject var synchronization: Synchronization

    @State private var showFlipperDisconnected: Bool = false
    @State private var showFlipperNotSupported: Bool = false
    @State private var showFlipperSyncing: Bool = false

    var body: some View {
        Button { openInfraredLibrary() } label: {
            InfraredLibraryCard()
        }
        .alert(isPresented: $showFlipperDisconnected) {
            DeviceDisconnectedAlert(isPresented: $showFlipperDisconnected)
        }
        .alert(isPresented: $showFlipperNotSupported) {
            NotSupportedFeatureAlert(isPresented: $showFlipperNotSupported)
        }
        .alert(isPresented: $showFlipperSyncing) {
            PauseSyncAlert(isPresented: $showFlipperSyncing) {
                synchronization.cancelSync()
                onTap()
                recordInfraredLibraryOpened()
            }
        }
    }

    private func openInfraredLibrary() {
        guard let flipper = device.flipper else {
            showFlipperDisconnected = true
            return
        }

        switch device.status {
        case .connected, .synchronized:
            guard flipper.hasInfraredEmulateSupport else {
                showFlipperNotSupported = true
                return
            }
        case .synchronizing:
            showFlipperSyncing = true
            return
        default:
            showFlipperDisconnected = true
            return
        }

        onTap()
        recordInfraredLibraryOpened()
    }

    // MARK: Analytics

    private func recordInfraredLibraryOpened() {
        analytics.appOpen(target: .infraredLibraryOpen)
    }
}
