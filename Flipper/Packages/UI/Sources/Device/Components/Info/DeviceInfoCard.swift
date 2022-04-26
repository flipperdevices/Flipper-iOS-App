import Core
import Peripheral
import SwiftUI

struct DeviceInfoCard: View {
    @StateObject var viewModel: DeviceInfoCardViewModel

    var body: some View {
        Card {
            VStack(spacing: 0) {
                HStack {
                    Text("Device Info")
                        .font(.system(size: 16, weight: .bold))
                    Spacer()
                }
                .padding(.top, 12)
                .padding(.horizontal, 12)

                if viewModel.isInfoLoaded {
                    VStack(spacing: 12) {
                        DeviceInfoCardRow(
                            name: "Firmware Version",
                            value: viewModel.firmwareVersion
                        )
                        .foregroundColor(viewModel.firmwareVersionColor)
                        .padding(.horizontal, 12)
                        Divider()
                        DeviceInfoCardRow(
                            name: "Build Date",
                            value: viewModel.firmwareBuild
                        )
                        .padding(.horizontal, 12)

                        Divider()
                        DeviceInfoCardRow(
                            name: "Int. Flash (Used/Total)",
                            value: viewModel.internalSpace
                        )
                        .padding(.horizontal, 12)

                        Divider()
                        DeviceInfoCardRow(
                            name: "SD Card (Used/Total)",
                            value: viewModel.externalSpace
                        )
                        .padding(.horizontal, 12)

                        HStack {
                            Text("Full info")
                            Image(systemName: "chevron.right")
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black16)
                        .padding(.top, 5)
                    }
                    .padding(.top, 18)
                    .padding(.bottom, 12)
                } else if viewModel.isDisconnected || viewModel.isNoDevice {
                    VStack(spacing: 2) {
                        Image("InfoNoDevice")
                        Text("Connect to Flipper to see device info")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.black30)
                    }
                    .padding(.vertical, 62)
                } else {
                    VStack(spacing: 4) {
                        Spinner()
                        Text("Connecting to Flipper...")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.black30)
                    }
                    .padding(.top, 82)
                    .padding(.bottom, 62)
                }
            }
        }
    }
}

struct Spinner: View {
    var body: some View {
        Animation("Loading")
            .frame(width: 40, height: 40)
            .scaledToFill()
    }
}
