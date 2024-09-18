import Core
import SwiftUI

struct InfraredLibraryCard: View {

    var body: some View {
        HubCard(
            icon: "infrared",
            title: "Infrared",
            image: "InfraredRemoteLibrary",
            subtitle: "Remotes Library",
            description: "Find remotes for your devices from a "
                        + "wide range of brands and models"
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

    @State private var showFlipperDisconnected: Bool = false
    @State private var showFlipperNotSupported: Bool = false

    var body: some View {
        Button { openInfraredLibrary() } label: {
            InfraredLibraryCard()
        }
        .alert(isPresented: $showFlipperDisconnected) {
            DeviceDisconnectedAlert(
                isPresented: $showFlipperDisconnected)
        }
        .alert(isPresented: $showFlipperNotSupported) {
            NotSupportedFeatureAlert(
                isPresented: $showFlipperNotSupported)
        }
    }

    private func openInfraredLibrary() {
        guard
            let flipper = device.flipper,
            device.status == .connected
        else {
            showFlipperDisconnected = true
            return
        }

        guard flipper.hasInfraredEmulateSupport else {
            showFlipperNotSupported = true
            return
        }

        onTap()
    }
}
