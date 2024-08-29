import Core
import SwiftUI

extension ArchiveView {
    struct CategoryView: View {
        @EnvironmentObject var archive: ArchiveModel
        @EnvironmentObject private var device: Device

        @Environment(\.path) private var path
        @Environment(\.dismiss) private var dismiss

        @State private var showFlipperDisconnected: Bool = false
        @State private var showFlipperNotSupported: Bool = false

        let kind: ArchiveItem.Kind

        var items: [ArchiveItem] {
            archive.items.filter { $0.kind == kind }
        }

        var body: some View {
            ZStack {
                Text("You have no keys yet")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black40)
                    .opacity(items.isEmpty ? 1 : 0)

                ScrollView {
                    CategoryList(items: items) { item in
                        path.append(Destination.info(item))
                    }
                    .padding(14)
                }
            }
            .background(Color.background)
            .navigationBarBackground(Color.a1)
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                LeadingToolbarItems {
                    BackButton {
                        dismiss()
                    }
                    Text(kind.name)
                        .font(.system(size: 20, weight: .bold))
                }

                if kind == .infrared {
                    TrailingToolbarItems {
                        NavBarButton {
                            addInfraredRemote()
                        } label: {
                            Text("Add Remote")
                                .font(.system(size: 14, weight: .bold))
                                .padding(.horizontal, 14)
                        }
                    }
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
        }

        private func addInfraredRemote() {
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
}
