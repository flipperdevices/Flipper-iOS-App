import Core
import SwiftUI

struct DeviceView: View {
    @StateObject var viewModel: DeviceViewModel
    @State private var action: String?

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                DeviceHeader(device: viewModel.device)

                ScrollView {
                    VStack {
                        NavigationLink {
                            DeviceInfoView(viewModel: .init())
                        } label: {
                            DeviceInfoSection(
                                protobufVersion: viewModel.protobufVersion,
                                firmwareVersion: viewModel.firmwareVersion,
                                firmwareBuild: viewModel.firmwareBuild,
                                internalSpace: viewModel.internalSpace,
                                externalSpace: viewModel.externalSpace
                            )
                        }
                        .disabled(viewModel.device?.state != .connected)

                        VStack(spacing: 14) {
                            DeviceActionButton(
                                image: "Sync",
                                title: "Synchronize"
                            ) {
                                viewModel.sync()
                            }
                            .disabled(viewModel.status == .synchronizing)
                            .disabled(viewModel.device?.state != .connected)

                            if viewModel.device == nil {
                                DeviceActionButton(
                                    image: "Connect",
                                    title: "Connect Flipper"
                                ) {
                                    viewModel.showWelcomeScreen()
                                }
                            } else {
                                DeviceActionButton(
                                    image: "Forget",
                                    title: "Forget Flipper"
                                ) {
                                    viewModel.showWelcomeScreen()
                                }
                                .foregroundColor(.red)
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.bottom, 14)
                    }
                }
                .background(Color.background)
            }
            .navigationBarHidden(true)
            .alert(isPresented: $viewModel.isPairingIssue) {
                .pairingIssue
            }
            .navigationBarColors(foreground: .primary, background: .header)
        }
    }
}
