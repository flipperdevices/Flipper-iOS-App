import Core
import Catalog

import SwiftUI

struct HubView: View {
    @State var showRemoteControl = false

    @EnvironmentObject var applications: Applications

    @AppStorage(.isAppsEnabled) var isAppsEnabled = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 14) {
                    if isAppsEnabled {
                        NavigationLink {
                            AppsView()
                                .environmentObject(applications)
                        } label: {
                            AppsRowCard()
                                .environmentObject(applications)
                        }
                    }

                    HStack(spacing: 14) {
                        Button {
                            showRemoteControl = true
                        } label: {
                            RemoteControlCard()
                        }

                        NavigationLink {
                            NFCToolsView()
                        } label: {
                            NFCCard()
                        }
                    }
                }
                .padding(14)
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
                RemoteControlView()
                    .modifier(AlertControllerModifier())
            }
        }
        .navigationViewStyle(.stack)
        .navigationBarColors(foreground: .primary, background: .a1)
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
}

// TODO: Refactor alerts
private struct AlertControllerModifier: ViewModifier {
    @StateObject private var alertController: AlertController = .init()

    func body(content: Content) -> some View {
        ZStack {
            content
                .environmentObject(alertController)

            if alertController.isPresented {
                alertController.alert
            }
        }
    }
}
