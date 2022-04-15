import Core
import Peripheral
import SwiftUI

struct DeviceInfoCard: View {
    @StateObject var viewModel: DeviceInfoCardViewModel

    var body: some View {
        Card {
            VStack(spacing: 18) {
                HStack {
                    Text("Device Info")
                        .font(.system(size: 16, weight: .bold))
                    Spacer()
                }
                .padding(.top, 12)
                .padding(.horizontal, 12)

                VStack(spacing: 12) {
                    DeviceInfoCardRow(
                        name: "Firmware Version",
                        value: viewModel.firmwareVersion
                    )
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

                    if viewModel.isConnected {
                        HStack {
                            Text("Full info")
                            Image(systemName: "chevron.right")
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black16)
                        .padding(.top, 6)
                    }
                }
                .padding(.bottom, 12)
            }
        }
    }
}
