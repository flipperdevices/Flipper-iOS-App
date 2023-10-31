import Core
import Catalog

import SwiftUI

struct HubView: View {
    @State var showRemoteControl = false

    @EnvironmentObject var applications: Applications

    @AppStorage(.selectedTabKey) var selectedTab: TabView.Tab = .device
    @State private var applicationAlias: String?
    @State private var showApplication = false
    @State private var showDetectReader = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 14) {
                    NavigationLink {
                        AppsView()
                            .environmentObject(applications)
                    } label: {
                        AppsRowCard()
                            .environmentObject(applications)
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

                NavigationLink("", isActive: $showApplication) {
                    if let applicationAlias {
                        AppView(alias: applicationAlias)
                    }
                }
            }
            .background(Color.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                LeadingToolbarItems {
                    Title("Hub")
                        .padding(.leading, 8)
                }
            }
            .sheet(isPresented: $showRemoteControl) {
                AlertStack {
                    RemoteControlView()
                }
            }
        }
        .onOpenURL { url in
            if url.isApplicationURL {
                applicationAlias = url.applicationAlias
                selectedTab = .hub
                showApplication = true
            } else if url == .mfkey32Link {
                selectedTab = .hub
                showDetectReader = true
            }
        }
        .navigationViewStyle(.stack)
        .navigationBarColors(foreground: .primary, background: .a1)
        .fullScreenCover(isPresented: $showDetectReader) {
            AlertStack {
                DetectReaderView()
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
