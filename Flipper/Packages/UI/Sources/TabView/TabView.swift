import SwiftUI
import Core

struct TabView: View {
    @StateObject var viewModel: TabViewModel
    @Binding var selected: Tab

    enum Tab: String {
        case device
        case archive
        case hub
    }

    func color(for tab: Tab) -> Color {
        selected == tab ? .accentColor : .secondary
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                TabViewItem(
                    image: deviceImage,
                    name: deviceTabName,
                    isSelected: selected == .device,
                    hasNotification: false
                ) {
                    self.selected = .device
                }
                .foregroundColor(deviceColor)

                Spacer()

                TabViewItem(
                    image: .init(Image(archiveImageName)),
                    name: "Archive",
                    isSelected: selected == .archive,
                    hasNotification: false
                ) {
                    self.selected = .archive
                }
                .foregroundColor(archiveColor)

                Spacer()

                TabViewItem(
                    image: .init(Image(hubImageName)),
                    name: "Hub",
                    isSelected: selected == .hub,
                    hasNotification: viewModel.hasMFLog
                ) {
                    self.selected = .hub
                }
                .foregroundColor(hubColor)
            }
            .padding(.top, 6)
            .padding(.horizontal, 8)
        }
        .frame(height: tabViewHeight + bottomSafeArea + 9, alignment: .top)
        .background(systemBackground)
    }
}

extension TabView {
    var deviceTabName: String {
        switch viewModel.status {
        case .noDevice: return "No Device"
        case .unsupportedDevice: return "Unsupported"
        case .connecting: return "Connecting..."
        case .connected: return "Connected"
        case .disconnected: return "Disconnected"
        case .synchronizing: return "Syncing \(viewModel.syncProgress)%"
        case .synchronized: return "Synced!"
        case .updating: return "Connecting..."
        case .invalidPairing: return "Pairing Failed"
        case .pairingFailed: return "Pairing Failed"
        }
    }
}

extension TabView {
    var deviceColor: Color {
        guard selected == .device else {
            return .black30
        }
        switch viewModel.status {
        case .noDevice: return .black40
        case .unsupportedDevice: return .sRed
        case .connecting: return .black40
        case .connected: return .a2
        case .disconnected: return .black40
        case .synchronizing: return .a2
        case .synchronized: return .a2
        case .updating: return .black40
        case .invalidPairing: return .sRed
        case .pairingFailed: return .sRed
        }
    }

    var archiveColor: Color {
        selected == .archive ? .black80 : .black30
    }

    var hubColor: Color {
        selected == .hub ? .black80 : .black30
    }
}

extension TabView {
    var deviceImage: AnyView {
        switch viewModel.status {
        case .connecting, .synchronizing:
            return .init(
                Animation(deviceImageName + "_animated")
                    .frame(width: 42, height: 24))
        default:
            return .init(Image(deviceImageName))
        }
    }

    var deviceImageName: String {
        var name = "device_"
        name += selected == .device ? "filled_" : "line_"

        switch viewModel.status {
        case .noDevice: name += "no_device"
        case .unsupportedDevice: name += "unsupported"
        case .connecting: name += "connecting"
        case .connected: name += "connected"
        case .disconnected: name += "disconnected"
        case .synchronizing: name += "syncing"
        case .synchronized: name += "synced"
        case .updating: name += "connecting"
        case .invalidPairing: name += "pairing_failed"
        case .pairingFailed: name += "pairing_failed"
        }

        return name
    }

    var archiveImageName: String {
        selected == .archive ? "archive_filled_icon" : "archive_line_icon"
    }

    var hubImageName: String {
        selected == .hub ? "hub_filled_icon" : "hub_line_icon"
    }
}
