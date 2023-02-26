import Core
import SwiftUI

struct TabView: View {
    @EnvironmentObject var device: Device
    @EnvironmentObject var syncService: SyncService
    @Binding var selected: Tab
    var extraAction: () -> Void

    @AppStorage(.hasReaderLog) var hasReaderLog = false

    enum Tab: String, CaseIterable {
        case device
        case archive
        case hub
    }

    func color(for tab: Tab) -> Color {
        selected == tab ? .accentColor : .secondary
    }

    func handleTap(on tab: Tab) {
        switch selected {
        case tab: extraAction()
        default: selected = tab
        }
    }

    var body: some View {
        Group {
            HStack(alignment: .top) {
                TabViewItem(
                    image: deviceImage,
                    name: deviceTabName,
                    isSelected: selected == .device,
                    hasNotification: false
                ) {
                    handleTap(on: .device)
                }
                .foregroundColor(deviceColor)

                Spacer()

                TabViewItem(
                    image: .init(Image(archiveImageName)),
                    name: "Archive",
                    isSelected: selected == .archive,
                    hasNotification: false
                ) {
                    handleTap(on: .archive)
                }
                .foregroundColor(archiveColor)

                Spacer()

                TabViewItem(
                    image: .init(Image(hubImageName)),
                    name: "Hub",
                    isSelected: selected == .hub,
                    hasNotification: hasReaderLog
                ) {
                    handleTap(on: .hub)
                }
                .foregroundColor(hubColor)
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 8)
        }
        .background(systemBackground)
    }
}

extension TabView {
    var deviceTabName: String {
        switch device.status {
        case .noDevice: return "No Device"
        case .unsupported: return "Unsupported"
        case .connecting: return "Connecting..."
        case .connected: return "Connected"
        case .disconnected: return "Disconnected"
        case .synchronizing: return "Syncing \(syncService.syncProgress)%"
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
        switch device.status {
        case .noDevice: return .black40
        case .unsupported: return .sRed
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
        switch device.status {
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

        switch device.status {
        case .noDevice: name += "no_device"
        case .unsupported: name += "unsupported"
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
