import Core
import Catalog

import SwiftUI

struct HubView: View {
    @AppStorage(.selectedTab) var selectedTab: TabView.Tab = .device
    @AppStorage(.hasReaderLog) var hasReaderLog = false

    @State private var showDetectReader = false
    @State private var path = NavigationPath()

    enum Destination: Hashable {
        case infrared
    }

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(spacing: 14) {
                    Button { showDetectReader = true } label: {
                        DetectReaderCard(hasNotification: hasReaderLog)
                    }
                    InfraredLibraryCardButton {
                        path.append(Destination.infrared)
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
            .navigationDestination(for: Destination.self) { destination in
                switch destination {
                case .infrared: InfraredView()
                }
            }
        }
        .environment(\.path, $path)
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
