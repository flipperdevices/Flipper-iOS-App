import SwiftUI
import Core

struct TabView: View {
    @Binding var selected: Tab
    let status: Status

    enum Tab: String {
        case device
        case archive
        case options
    }

    func color(for tab: Tab) -> Color {
        selected == tab ? .accentColor : .secondary
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                TabViewItem(
                    image: deviceImageName,
                    name: deviceTabName,
                    isSelected: selected == .device
                ) {
                    self.selected = .device
                }
                .foregroundColor(deviceColor)

                Spacer()

                TabViewItem(
                    image: archiveImageName,
                    name: "Archive",
                    isSelected: selected == .archive
                ) {
                    self.selected = .archive
                }
                .foregroundColor(archiveColor)

                Spacer()

                TabViewItem(
                    image: optionsImageName,
                    name: "Options",
                    isSelected: selected == .options
                ) {
                    self.selected = .options
                }
                .foregroundColor(optionsColor)
            }
            .padding(.vertical, 3)
            .padding(.horizontal, 17)
        }
        .frame(height: tabViewHeight + bottomSafeArea, alignment: .top)
        .background(systemBackground)
    }
}

extension TabView {
    var deviceTabName: String {
        switch status {
        case .noDevice: return "No Device"
        case .connecting: return "Connecting..."
        case .connected: return "Connected"
        case .disconnected: return "Disconnected"
        case .synchronizing: return "Syncing..."
        case .synchronized: return "Synced!"
        case .pairingIssue: return "Pairing Issue"
        case .preParing: return "PreParing..."
        case .pairing: return "Pairing..."
        case .failed: return "Sync Failed"
        }
    }
}

extension TabView {
    var deviceColor: Color {
        guard selected == .device else {
            return .black30
        }
        switch status {
        case .noDevice: return .black40
        case .connecting: return .accentColor
        case .connected: return .accentColor
        case .disconnected: return .black40
        case .synchronizing: return .accentColor
        case .synchronized: return .accentColor
        case .pairingIssue: return .red
        case .preParing: return .accentColor
        case .pairing: return .accentColor
        case .failed: return .red
        }
    }

    var archiveColor: Color {
        selected == .archive ? .black80 : .black30
    }

    var optionsColor: Color {
        selected == .options ? .black80 : .black30
    }
}

extension TabView {
    var deviceImageName: String {
        var name = "flipper_status_"
        name += selected == .device ? "field_" : "line_"

        switch status {
        case .noDevice: name += "no_device"
        case .connecting: name += "connecting"
        case .connected: name += "connected"
        case .disconnected: name += "disconnected"
        case .synchronizing: name += "syncing"
        case .synchronized: name += "synced"
        case .pairingIssue: name += "failed"
        case .preParing: name += "connecting"
        case .pairing: name += "connecting"
        case .failed: name += "failed"
        }

        return name
    }

    var archiveImageName: String {
        selected == .archive ? "archive_filled_icon" : "archive_line_icon"
    }

    var optionsImageName: String {
        selected == .options ? "options_filled_icon" : "options_line_icon"
    }
}
