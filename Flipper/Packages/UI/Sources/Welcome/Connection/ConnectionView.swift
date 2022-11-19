import Core
import SwiftUI

struct ConnectionView: View {
    @StateObject var viewModel: ConnectionViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            switch self.viewModel.state {
            case .notReady(let reason):
                if reason == .unauthorized {
                    BluetoothAccessView()
                } else {
                    BluetoothOffView()
                }
            case .ready:
                HStack(spacing: 0) {
                    HStack(spacing: 8) {
                        Text("Searching")
                        ProgressView()
                    }
                    .opacity(viewModel.isScanTimeout ? 0 : 1)

                    alertsHack()

                    Spacer()

                    Button {
                        viewModel.showHelpSheet = true
                    } label: {
                        HStack(spacing: 7) {
                            Text("Help")
                            Image(systemName: "questionmark.circle.fill")
                                .resizable()
                                .frame(width: 22, height: 22)
                        }
                    }
                    .foregroundColor(.black40)
                }
                .font(.system(size: 16, weight: .medium))
                .padding(.bottom, 32)
                .padding(.top, 74)

                if viewModel.flippers.isEmpty {
                    if viewModel.isScanTimeout {
                        ScanTimeoutView {
                            viewModel.startScan()
                        }
                    } else {
                        ConnectPlaceholderView()
                            .padding(.bottom, 77)
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 14) {
                            ForEach(viewModel.flippers) { flipper in
                                row(for: flipper)
                            }
                        }
                    }
                }
            }

            Spacer()
            Button("Skip connection") {
                viewModel.skipConnection()
            }
            .padding(.bottom, onMac ? 140 : 8)
            .disabled(viewModel.isConnecting)
        }
        .padding(.horizontal, 16)
        .background(Color.background)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            LeadingToolbarItems {
                BackButton {
                    dismiss()
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Connect your Flipper")
                    .font(.system(size: 22, weight: .bold))
            }
        }
        .sheet(isPresented: $viewModel.showHelpSheet) {
            HelpView()
                .customBackground(Color.background)
        }
        .onDisappear {
            viewModel.stopScan()
        }
        .navigationBarColors(foreground: .primary, background: Color.background)
    }

    func row(for flipper: Flipper) -> some View {
        HStack(spacing: 0) {
            HStack(spacing: 0) {
                VStack(spacing: 6) {
                    Image("DeviceConnect")
                    Text("Flipper Zero")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.black30)
                }
                .padding(.horizontal, 14)

                Divider()

                Text(flipper.name)
                    .lineLimit(1)
                    .font(.system(size: 14, weight: .medium))
                    .padding(.leading, 14)

                Spacer(minLength: 0)

                switch flipper.state {
                case .connecting, .connected:
                    ProgressView()
                        .padding(.trailing, 14)
                default:
                    Button {
                        if flipper.state != .connected {
                            viewModel.connect(to: flipper.id)
                        }
                    } label: {
                        Text("Connect")
                            .roundedButtonStyle(horizontalPadding: 20)
                            .lineLimit(1)
                    }
                    .disabled(viewModel.isConnecting)
                    .padding(.trailing, 14)
                }
            }
        }
        .background(Color.groupedBackground)
        .frame(height: 64)
        .cornerRadius(10)
        .shadow(color: .shadow, radius: 16, x: 0, y: 4)
    }

    // TODO: Replace with new API on iOS15
    func alertsHack() -> some View {
        HStack {
            Spacer()
                .alert(isPresented: $viewModel.isConnectTimeout) {
                    .connectionTimeout {
                        viewModel.stopScan()
                        viewModel.startScan()
                    }
                }
            Spacer()
                .alert(isPresented: $viewModel.isCanceledOrInvalidPin) {
                    .canceledOrIncorrectPin {
                        viewModel.reconnect()
                    }
                }
        }
    }
}

struct ConnectPlaceholderView: View {
    var body: some View {
        VStack(spacing: 28) {
            Spacer()
            HStack {
                Image("PhonePlaceholder")
                Animation("Dots")
                    .frame(width: 32, height: 32)
                    .padding(.horizontal, 8)
                Image("DevicePlaceholder")
            }
            .frame(width: 208)
            Text("Turn On Bluetooth on your Flipper")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.black40)
            Spacer()
        }
    }
}
