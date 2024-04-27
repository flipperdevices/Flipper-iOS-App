import Core
import SwiftUI

struct TabView: View {
    @EnvironmentObject var device: Device
    @EnvironmentObject var synchronization: Synchronization
    @EnvironmentObject var applications: Applications

    @Binding var selected: Tab
    var extraAction: () -> Void

    @AppStorage(.hasReaderLog) var hasReaderLog = false

    var hasAppUpdates: Bool {
        applications.outdatedCount > 0
    }

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
                    hasNotification: hasReaderLog || hasAppUpdates
                ) {
                    handleTap(on: .hub)
                }
                .foregroundColor(hubColor)
            }
            .padding(3)
        }
        .background(systemBackground)
    }
}

extension TabView {
    var deviceTabName: String {
        switch device.status {
        case .noDevice: return "No Device"
        case .unsupported: return "Unsupported"
        case .outdatedMobile: return "Outdated App"
        case .connecting: return "Connecting..."
        case .connected: return "Connected"
        // TODO: Think about .notConnected state
        case .disconnected: return "Not Connected"
        case .synchronizing: return "Syncing \(synchronization.progress)%"
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
        return device.status.color
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
        return .init(
            DeviceTabView(
                status: device.status,
                isActiveTab: selected == .device
            )
        )
    }

    var archiveImageName: String {
        selected == .archive ? "archive_filled_icon" : "archive_line_icon"
    }

    var hubImageName: String {
        selected == .hub ? "hub_filled_icon" : "hub_line_icon"
    }
}
