import Core
import Catalog

import SwiftUI

struct HubView: View {
    @EnvironmentObject var device: Device

    @Environment(\.notifications) private var notifications

    @AppStorage(.selectedTab) var selectedTab: TabView.Tab = .device
    @AppStorage(.hasReaderLog) var hasReaderLog = false

    @State private var showDetectReader = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    Button {
                        showDetectReader = true
                    } label: {
                        DetectReaderCard(hasNotification: hasReaderLog)
                    }
                }
                .padding(14)
            }
            .background(Color.background)
            .navigationBarBackground(Color.a1)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                LeadingToolbarItems {
                    Title("Tools")
                        .padding(.leading, 8)
                }
            }
        }
        .onOpenURL { url in
            if url == .mfkey32Link {
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
            NavigationCard(
                name: "NFC Tools",
                description:
                    "Calculate MIFARE Classic card keys using Flipper Zero",
                image: "nfc",
                hasNotification: hasReaderLog
            )
        }
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
