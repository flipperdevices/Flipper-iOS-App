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

                if viewModel.isUpdating {
                    VStack(spacing: 4) {
                        Spinner()
                        Text(
                            "Waiting for Flipper to finish update.\n" +
                            "Reconnecting..."
                        )
                        .multilineTextAlignment(.center)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black30)
                    }
                    .padding(.top, 66)
                    .padding(.bottom, 62)
                } else if viewModel.isDisconnected || viewModel.isNoDevice {
                    VStack(spacing: 2) {
                        Image("InfoNoDevice")
                        Text("Connect to Flipper to see device info")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.black30)
                    }
                    .padding(.vertical, 62)
                } else {
                    VStack(spacing: 12) {
                        CardRow(
                            name: "Firmware Version",
                            value: viewModel.firmwareVersion
                        )
                        .foregroundColor(viewModel.firmwareVersionColor)
                        .padding(.horizontal, 12)
                        Divider()
                        CardRow(
                            name: "Build Date",
                            value: viewModel.firmwareBuild
                        )
                        .padding(.horizontal, 12)

                        Divider()
                        if #available(iOS 15, *) {
                            CardRow(
                                name: "Int. Flash (Used/Total)",
                                value: viewModel.internalSpaceAttributed
                            )
                            .padding(.horizontal, 12)
                        } else {
                            CardRow(
                                name: "Int. Flash (Used/Total)",
                                value: viewModel.internalSpace
                            )
                            .padding(.horizontal, 12)
                        }
                        Divider()
                        if #available(iOS 15, *) {
                            CardRow(
                                name: "SD Card (Used/Total)",
                                value: viewModel.externalSpaceAttributed
                            )
                            .padding(.horizontal, 12)
                        } else {
                            CardRow(
                                name: "SD Card (Used/Total)",
                                value: viewModel.externalSpace
                            )
                            .padding(.horizontal, 12)
                        }

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
                }
            }
        }
    }
}
