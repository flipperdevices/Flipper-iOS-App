import Core
import Catalog

import SwiftUI

struct HubView: View {
    @EnvironmentObject var device: Device

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
}

extension URL {
    var isApplicationURL: Bool {
        (host == "lab.flipp.dev" || host == "lab.flipper.net")
        && pathComponents.count == 3
        && pathComponents[1] == "apps"
    }
}
