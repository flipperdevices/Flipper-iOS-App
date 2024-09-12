import Core
import Catalog

import SwiftUI

struct HubView: View {
    @EnvironmentObject var device: Device

    @AppStorage(.selectedTab) var selectedTab: TabView.Tab = .device
    @AppStorage(.hasReaderLog) var hasReaderLog = false

    @State private var showDetectReader = false
    @State private var showFlipperDisconnected: Bool = false
    @State private var showFlipperNotSupported: Bool = false

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
                    Button { openInfraredLibrary() } label: {
                        InfraredLibraryCard()
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
            .alert(isPresented: $showFlipperDisconnected) {
                DeviceDisconnectedAlert(
                    isPresented: $showFlipperDisconnected)
            }
            .alert(isPresented: $showFlipperNotSupported) {
                NotSupportedFeatureAlert(
                    isPresented: $showFlipperNotSupported)
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

    private func openInfraredLibrary() {
        guard
            let flipper = device.flipper,
            device.status == .connected
        else {
            showFlipperDisconnected = true
            return
        }

        guard flipper.hasInfraredEmulateSupport else {
            showFlipperNotSupported = true
            return
        }

        path.append(Destination.infrared)
    }
}

extension URL {
    var isApplicationURL: Bool {
        (host == "lab.flipp.dev" || host == "lab.flipper.net")
        && pathComponents.count == 3
        && pathComponents[1] == "apps"
    }
}
