import Core
import Catalog

import SwiftUI

struct HubView: View {
    @EnvironmentObject var applications: Applications
    @EnvironmentObject var device: Device
    @EnvironmentObject var router: Router

    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.notifications) private var notifications

    @AppStorage(.selectedTab) var selectedTab: TabView.Tab = .device

    @State private var path = NavigationPath()
    @State private var showRemoteControl = false
    @State private var showDetectReader = false

    enum Destination: Hashable {
        case applications(AppsSegments.Segment)
        case application(String)
        case category(Applications.Category)
    }

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(spacing: 14) {
                    NavigationLink(value: Destination.applications(.all)) {
                        AppsRowCard()
                            .environmentObject(applications)
                    }
                    .onReceive(router.showApps) {
                        path.removeLast(path.count)
                        path.append(Destination.applications(.installed))
                        selectedTab = .hub
                    }
                    .analyzingTapGesture {
                        recordAppsOpened()
                    }

                    HStack(spacing: 14) {
                        Button {
                            showRemoteControl = true
                        } label: {
                            RemoteControlCard()
                        }

                        NavigationLink {
                            NFCToolsView($showDetectReader)
                        } label: {
                            NFCCard()
                        }
                    }
                }
                .padding(14)
            }
            .background(Color.background)
            .navigationBarBackground(Color.a1)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                LeadingToolbarItems {
                    Title("Hub")
                        .padding(.leading, 8)
                }
            }
            .sheet(isPresented: $showRemoteControl) {
                RemoteControlView()
                    .environmentObject(device)
            }
            .navigationDestination(for: Destination.self) { destination in
                switch destination {
                case .applications(let segment):
                    AppsView(initialSegment: segment)
                case .application(let alias):
                    AppView(alias: alias)
                case .category(let category):
                    AppsCategoryView(category: category)
                }
            }
        }
        .onOpenURL { url in
            if url.isApplicationURL, let alias = url.applicationAlias {
                path.append(Destination.application(alias))
                selectedTab = .hub
            } else if url == .mfkey32Link {
                selectedTab = .hub
                showDetectReader = true
            }
        }
        .fullScreenCover(isPresented: $showDetectReader) {
            DetectReaderView()
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active: applications.enableProgressUpdates = true
            case .inactive: applications.enableProgressUpdates = false
            case .background: break
            @unknown default: break
            }
        }
    }

    struct NFCCard: View {
        @AppStorage(.hasReaderLog) var hasReaderLog = false

        var body: some View {
            HubCardSmall(
                name: "NFC Tools",
                description:
                    "Calculate MIFARE Classic card keys using Flipper Zero",
                image: "nfc",
                hasNotification: hasReaderLog
            )
        }
    }

    struct RemoteControlCard: View {
        var body: some View {
            HubCardSmall(
                name: "Remote Control",
                description:
                    "Control your Flipper Zero remotely via mobile phone",
                image: "HubRemoteControl",
                hasNotification: false
            )
        }
    }

    // MARK: Analytics

    func recordAppsOpened() {
        analytics.appOpen(target: .fapHub)
    }
}

extension URL {
    var isApplicationURL: Bool {
        (host == "lab.flipp.dev" || host == "lab.flipper.net")
        && pathComponents.count == 3
        && pathComponents[1] == "apps"
    }

    var applicationAlias: String? {
        guard pathComponents.count == 3, !pathComponents[2].isEmpty else {
            return nil
        }
        return pathComponents[2]
    }
}
