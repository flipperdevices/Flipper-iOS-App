import Core
import Catalog

import SwiftUI

struct HubView: View {
    @EnvironmentObject var applications: Applications
    @EnvironmentObject var device: Device
    @EnvironmentObject var router: Router

    @Environment(\.notifications) private var notifications

    @AppStorage(.selectedTab) var selectedTab: TabView.Tab = .device

    @State private var appsState: AppsState = .init()
    @State private var showRemoteControl = false
    @State private var showDetectReader = false

    struct AppsState {
        var showApplications = false
        var applicationAlias: String?
        var showApplication = false
        var selectedSegment: AppsSegments.Segment = .all
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    NavigationLink(isActive: $appsState.showApplications) {
                        AppsView(selectedSegment: $appsState.selectedSegment)
                            .environmentObject(applications)
                    } label: {
                        AppsRowCard()
                            .environmentObject(applications)
                    }
                    .onReceive(router.showApps) {
                        appsState.selectedSegment = .installed
                        appsState.showApplications = true
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

                NavigationLink("", isActive: $appsState.showApplication) {
                    if let applicationAlias = appsState.applicationAlias{
                        AppView(alias: applicationAlias)
                    }
                }
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
        }
        .onOpenURL { url in
            if url.isApplicationURL {
                appsState.applicationAlias = url.applicationAlias
                selectedTab = .hub
                appsState.showApplication = true
            } else if url == .mfkey32Link {
                selectedTab = .hub
                showDetectReader = true
            }
        }
        .fullScreenCover(isPresented: $showDetectReader) {
            DetectReaderView()
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
