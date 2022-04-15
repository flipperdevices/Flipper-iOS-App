import Core
import SwiftUI

struct DeviceView: View {
    @StateObject var viewModel: DeviceViewModel

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                DeviceHeader(device: viewModel.flipper)

                ScrollView {
                    VStack(spacing: 0) {
                        if viewModel.status == .unsupportedDevice {
                            UnsupportedDevice()
                                .padding(.top, 24)
                                .padding(.horizontal, 14)
                        } else {
                            DeviceUpdate {
                                viewModel.update()
                            }
                            .padding(.top, 24)
                            .padding(.horizontal, 14)
                        }

                        NavigationLink {
                            DeviceInfoView(viewModel: .init())
                        } label: {
                            DeviceInfoCard(viewModel: .init())
                                .padding(.top, 24)
                                .padding(.horizontal, 14)
                        }
                        .disabled(!viewModel.status.isOnline)

                        VStack(spacing: 24) {
                            if viewModel.status != .noDevice {
                                VStack(spacing: 0) {
                                    ActionButton(
                                        image: "Sync",
                                        title: "Synchronize"
                                    ) {
                                        viewModel.sync()
                                    }
                                    .disabled(!viewModel.canSync)

                                    Divider()

                                    ActionButton(
                                        image: "Alert",
                                        title: "Play Alert"
                                    ) {
                                        viewModel.playAlert()
                                    }
                                    .disabled(!viewModel.canPlayAlert)
                                }
                                .cornerRadius(10)
                            }

                            VStack(spacing: 0) {
                                if viewModel.status == .noDevice {
                                    ActionButton(
                                        image: "Connect",
                                        title: "Connect Flipper"
                                    ) {
                                        viewModel.connect()
                                    }
                                } else {
                                    if viewModel.canConnect {
                                        ActionButton(
                                            image: "Connect",
                                            title: "Connect"
                                        ) {
                                            viewModel.connect()
                                        }
                                    }

                                    if viewModel.canDisconnect {
                                        ActionButton(
                                            image: "Disconnect",
                                            title: "Disconnect"
                                        ) {
                                            viewModel.disconnect()
                                        }
                                    }

                                    Divider()

                                    if viewModel.canForget {
                                        ActionButton(
                                            image: "Forget",
                                            title: "Forget Flipper"
                                        ) {
                                            viewModel.showForgetActionSheet()
                                        }
                                        .foregroundColor(.sRed)
                                    }
                                }
                            }
                            .cornerRadius(10)
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
