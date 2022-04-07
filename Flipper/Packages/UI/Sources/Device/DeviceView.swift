import Core
import SwiftUI

struct DeviceView: View {
    @StateObject var viewModel: DeviceViewModel
    @State private var action: String?

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                DeviceHeader(device: viewModel.flipper)

                ScrollView {
                    VStack(spacing: 0) {
                        if viewModel.status == .unsupportedDevice {
                            UnsupportedDeviceSection()
                                .padding(.top, 14)
                                .padding(.horizontal, 14)
                        }

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
                            .padding(.top, 14)
                            .padding(.horizontal, 14)
                        }
                        .disabled(!viewModel.status.isOnline)

                        VStack(spacing: 24) {
                            if viewModel.status != .noDevice {
                                VStack(spacing: 12) {
                                    DeviceActionButton(
                                        image: "Sync",
                                        title: "Synchronize"
                                    ) {
                                        viewModel.sync()
                                    }
                                    .disabled(!viewModel.canSync)

                                    DeviceActionButton(
                                        image: "Alert",
                                        title: "Play Alert"
                                    ) {
                                        viewModel.playAlert()
                                    }
                                    .disabled(!viewModel.canPlayAlert)
                                }
                            }

                            VStack(spacing: 12) {
                                if viewModel.canConnect {
                                    DeviceActionButton(
                                        image: "Connect",
                                        title: "Connect Flipper"
                                    ) {
                                        viewModel.connect()
                                    }
                                }

                                if viewModel.canDisconnect {
                                    DeviceActionButton(
                                        image: "Forget",
                                        title: "Disconnect Flipper"
                                    ) {
                                        viewModel.disconnect()
                                    }
                                }

                                if viewModel.canForget {
                                    DeviceActionButton(
                                        image: "Forget",
                                        title: "Forget Flipper"
                                    ) {
                                        viewModel.showForgetActionSheet()
                                    }
                                    .foregroundColor(.sRed)
                                }
                            }
                        }
                        .padding(.vertical, 24)
                        .padding(.horizontal, 14)

                        Color.clear.alert(
                            isPresented: $viewModel.showPairingIssueAlert
                        ) {
                            .pairingIssue
                        }

                        Color.clear.alert(
                            isPresented: $viewModel.showUnsupportedVersionAlert
                        ) {
                            .unsupportedDeviceIssue
                        }
                    }
                }
                .background(Color.background)
                .actionSheet(isPresented: $viewModel.showForgetAction) {
                    .init(
                        title: Text("This action won't delete your keys"),
                        buttons: [
                            .destructive(Text("Foget Flipper")) {
                                viewModel.forgetFlipper()
                            },
                            .cancel()
                        ]
                    )
                }
            }
            .navigationViewStyle(.stack)
            .navigationBarHidden(true)
            .navigationBarColors(foreground: .primary, background: .a1)
        }
    }
}
