import Core
import SwiftUI

struct TabView: View {
    @EnvironmentObject var device: Device
    @EnvironmentObject var synchronization: Synchronization
    @EnvironmentObject var applications: Applications

    @Environment(\.colorScheme) var colorScheme

    @Binding var selected: Tab
    var extraAction: () -> Void

    @AppStorage(.hasReaderLog) var hasReaderLog = false

    var hasAppUpdates: Bool {
        applications.outdatedCount > 0
    }

    enum Tab: String, CaseIterable {
        case device
        case archive
        case apps
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

    struct Badge: View {
        let offset: Double

        var body: some View {
            Circle()
                .frame(width: 12, height: 12)
                .foregroundColor(.white)
                .overlay(alignment: .center) {
                    Circle()
                        .frame(width: 10, height: 10)
                        .foregroundColor(.sGreenUpdate)
                }
                .offset(x: offset, y: -2)
        }
    }

    var body: some View {
        Group {
            HStack(alignment: .top) {
                TabViewItem(
                    image: deviceImage,
                    name: deviceTabName,
                    isSelected: selected == .device
                ) {
                    handleTap(on: .device)
                }
                .foregroundColor(deviceColor)

                Spacer(minLength: 0)

                TabViewItem(
                    image: archiveImage,
                    name: "Archive",
                    isSelected: selected == .archive
                ) {
                    handleTap(on: .archive)
                }
                .foregroundColor(archiveColor)

                Spacer(minLength: 0)

                TabViewItem(
                    image: appsImage,
                    name: "Apps",
                    isSelected: selected == .apps
                ) {
                    handleTap(on: .apps)
                }
                .foregroundColor(appsColor)
                .analyzingTapGesture {
                    recordAppsOpened()
                }

                Spacer(minLength: 0)

                TabViewItem(
                    image: hubImage,
                    name: "Tools",
                    isSelected: selected == .hub
                ) {
                    handleTap(on: .hub)
                }
                .foregroundColor(hubColor)
            }
            .padding(3)
        }
        .background(systemBackground)
    }

    // MARK: Analytics

    func recordAppsOpened() {
        analytics.appOpen(target: .fapHub)
    }
}

private extension TabView {
    var deviceTabName: String {
        switch device.status {
        case .noDevice: return "No Device"
        case .unsupported: return "Unsupported"
        case .outdatedMobile: return "Outdated App"
        case .connecting: return "Connecting..."
        case .connected: return "Connected"
        // TODO: Think about .notConnected state
        case .disconnected: return "Not Connected"
        case .synchronizing: return "Syncing \(synchronization.progress.value)%"
        case .synchronized: return "Synced!"
        case .updating: return "Connecting..."
        case .invalidPairing: return "Pairing Failed"
        case .pairingFailed: return "Pairing Failed"
        }
    }
}

extension Device.Status {
    var color: Color {
        switch self {
        case .noDevice: .black40
        case .unsupported: .sRed
        case .outdatedMobile: .sRed
        case .connecting: .black40
        case .connected: .a2
        case .disconnected: .black40
        case .synchronizing: .a2
        case .synchronized: .a2
        case .updating: .black40
        case .invalidPairing: .sRed
        case .pairingFailed: .sRed
        }
    }
}

private extension TabView {
    var deviceColor: Color {
        guard selected == .device else { return .black30 }
        return device.status.color
    }

    var archiveColor: Color {
        guard selected == .archive else { return .black30 }
        return colorScheme == .light ? .black : .black30
    }

    var appsColor: Color {
        guard selected == .apps else { return .black30 }
        return colorScheme == .light ? .black : .black30
    }

    var hubColor: Color {
        guard selected == .hub else { return .black30 }
        return colorScheme == .light ? .black : .black30
    }
}

private extension TabView {
    var deviceImage: AnyView {
        .init(
            DeviceImage(
                status: device.status,
                style: selected == .device ? .fill : .stroke
            )
        )
    }

    var archiveImage: AnyView {
        .init(
            Image(archiveImageName)
                .renderingMode(.template)
        )
    }

    var appsImage: AnyView {
        .init(
            Image(appsImageName)
                .renderingMode(.template)
                .overlay(alignment: .topLeading) {
                    if hasAppUpdates {
                        Badge(offset: 24)
                    }
                }
        )
    }

    var hubImage: AnyView {
        .init(
            Image(hubImageName)
                .renderingMode(.template)
                .overlay(alignment: .topLeading) {
                    if hasReaderLog {
                        Badge(offset: 30)
                    }
                }
        )
    }

    var archiveImageName: String {
        selected == .archive ? "archive_filled_icon" : "archive_line_icon"
    }

    var appsImageName: String {
        selected == .apps ? "apps_filled_icon" : "apps_line_icon"
    }

    var hubImageName: String {
        selected == .hub ? "tools_filled_icon" : "tools_line_icon"
    }
}
