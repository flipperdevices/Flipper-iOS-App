import Core
import SwiftUI

private struct UsesVerticalToolbarKey: EnvironmentKey {
    static let defaultValue = false
}

private struct AdaptiveTabOwnerKey: EnvironmentKey {
    static let defaultValue: TabView.Tab? = nil
}

extension EnvironmentValues {
    var adaptiveTabOwner: TabView.Tab? {
        get { self[AdaptiveTabOwnerKey.self] }
        set { self[AdaptiveTabOwnerKey.self] = newValue }
    }

    var usesVerticalToolbar: Bool {
        get { self[UsesVerticalToolbarKey.self] }
        set { self[UsesVerticalToolbarKey.self] = newValue }
    }
}

struct AdaptiveToolbarLayout<Content: View>: View {
    @ViewBuilder var content: (Bool) -> Content

    var body: some View {
        if #available(iOS 27.1, *) {
            VerticalToolbarLayout(content: content)
        } else {
            content(false)
        }
    }
}

@available(iOS 27.1, *)
private struct VerticalToolbarLayout<Content: View>: View {
    @Environment(\.toolbarVerticalEdge) private var edge
    @ViewBuilder var content: (Bool) -> Content

    var body: some View {
        content(edge != nil)
            .environment(\.usesVerticalToolbar, edge != nil)
    }
}

extension View {
    func adaptiveTabBar(_ tab: TabView.Tab? = nil) -> some View {
        modifier(AdaptiveTabBarModifier(tab: tab))
    }
}

private struct AdaptiveTabBarModifier: ViewModifier {
    @EnvironmentObject var tabViewController: TabViewController
    @Environment(\.usesVerticalToolbar) private var usesVerticalToolbar
    @AppStorage(.selectedTab) var selected: TabView.Tab = .device
    @Environment(\.adaptiveTabOwner) private var inheritedTab
    let tab: TabView.Tab?

    private var owningTab: TabView.Tab? {
        tab ?? inheritedTab
    }

    func body(content: Content) -> some View {
        if #available(iOS 27.1, *) {
            content
                .environment(\.adaptiveTabOwner, owningTab)
                .toolbar {
                    if let owningTab, usesVerticalToolbar,
                        selected == owningTab {
                        AdaptiveTabToolbar()
                    }
                }
                .toolbarVisibility(
                    usesVerticalToolbar && !tabViewController.isHidden
                        ? .visible : .hidden,
                    for: .bottomBar
                )
        } else {
            content
        }
    }
}

@available(iOS 27.1, *)
struct AdaptiveTabToolbar: ToolbarContent {
    @EnvironmentObject var device: Device
    @EnvironmentObject var synchronization: Synchronization
    @EnvironmentObject var applications: Applications
    @EnvironmentObject var tabViewController: TabViewController
    @Environment(\.displayScale) private var displayScale
    @Environment(\.colorScheme) private var colorScheme

    @AppStorage(.selectedTab) var selected: TabView.Tab = .device
    @AppStorage(.hasReaderLog) var hasReaderLog = false

    var body: some ToolbarContent {
        ToolbarItem(placement: .bottomBar) {
            item(.device, title: deviceTabName) {
                Image(uiImage: deviceIcon)
                    .renderingMode(.original)
            }
        }
        .axisBehavior(.verticalPreferred)

        ToolbarItem(placement: .bottomBar) {
            item(.archive, title: "Archive") {
                Image(
                    selected == .archive
                        ? "archive_filled_icon" : "archive_line_icon"
                )
                .renderingMode(.template)
            }
        }
        .axisBehavior(.verticalPreferred)

        ToolbarItem(placement: .bottomBar) {
            item(.apps, title: "Apps") {
                Image(
                    selected == .apps
                        ? "apps_filled_icon" : "apps_line_icon"
                )
                .renderingMode(.template)
                .overlay(alignment: .topLeading) {
                    if applications.outdatedCount > 0 {
                        TabView.Badge(offset: 24)
                    }
                }
            }
        }
        .axisBehavior(.verticalPreferred)

        ToolbarItem(placement: .bottomBar) {
            item(.hub, title: "Tools") {
                Image(
                    selected == .hub
                        ? "tools_filled_icon" : "tools_line_icon"
                )
                .renderingMode(.template)
                .overlay(alignment: .topLeading) {
                    if hasReaderLog {
                        TabView.Badge(offset: 30)
                    }
                }
            }
        }
        .axisBehavior(.verticalPreferred)
    }

    private func item<Icon: View>(
        _ tab: TabView.Tab,
        title: String,
        @ViewBuilder icon: () -> Icon
    ) -> some View {
        Button {
            if selected == tab {
                tabViewController.popToRootView(for: tab)
            } else {
                selected = tab
            }
            if tab == .apps {
                analytics.appOpen(target: .fapHub)
            }
        } label: {
            Label(title: { Text(title) }, icon: icon)
        }
        .foregroundStyle(selected == tab
            ? (tab == .device ? device.status.color : Color.primary)
            : .black30)
        .accessibilityAddTraits(selected == tab ? .isSelected : [])
    }

    private var deviceTabName: String {
        switch device.status {
        case .noDevice: "No Device"
        case .unsupported: "Unsupported"
        case .outdatedMobile: "Outdated App"
        case .connecting: "Connecting..."
        case .connected: "Connected"
        case .disconnected: "Not Connected"
        case .synchronizing: "Syncing \(synchronization.progress.value)%"
        case .synchronized: "Synced!"
        case .updating: "Connecting..."
        case .invalidPairing, .pairingFailed: "Pairing Failed"
        }
    }

    @MainActor
    private var deviceIcon: UIImage {
        let renderer = ImageRenderer(content:
            TabView.DeviceImage(
                status: device.status,
                style: selected == .device ? .fill : .stroke)
                .foregroundColor(selected == .device
                    ? device.status.color : .black30)
                .environment(\.colorScheme, colorScheme))
        renderer.scale = displayScale
        return renderer.uiImage ?? UIImage()
    }
}
