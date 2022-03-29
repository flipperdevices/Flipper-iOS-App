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

                        VStack(spacing: 12) {
                            if viewModel.status != .noDevice {
                                DeviceActionButton(
                                    image: "Sync",
                                    title: "Synchronize"
                                ) {
                                    viewModel.sync()
                                }
                                .disabled(viewModel.status != .connected)
                            }

                            if viewModel.status != .noDevice {
                                DeviceActionButton(
                                    image: "Alert",
                                    title: "Play Alert"
                                ) {
                                    viewModel.playAlert()
                                }
                                .disabled(viewModel.status != .connected)
                            }

                            if viewModel.flipper == nil {
                                DeviceActionButton(
                                    image: "Connect",
                                    title: "Connect Flipper"
                                ) {
                                    viewModel.showWelcomeScreen()
                                }
                                .padding(.top, 12)
                            } else {
                                DeviceActionButton(
                                    image: "Forget",
                                    title: "Forget Flipper"
                                ) {
                                    viewModel.showWelcomeScreen()
                                }
                                .foregroundColor(.sRed)
                                .padding(.top, 12)
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
            }
            .navigationViewStyle(.stack)
            .navigationBarHidden(true)
            .navigationBarColors(foreground: .primary, background: .a1)
        }
    }
}
