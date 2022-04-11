import SwiftUI

struct DeviceInfoSection: View {
    let protobufVersion: String
    let firmwareVersion: String
    let firmwareBuild: String
    let internalSpace: String
    let externalSpace: String

    var body: some View {
        VStack(spacing: 18) {
            HStack {
                Text("Device Info")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
            }
            .padding(.top, 12)
            .padding(.horizontal, 12)

            VStack(spacing: 12) {
                DeviceInfoRow(
                    name: "Firmware Version",
                    value: firmwareVersion
                )
                .padding(.horizontal, 12)
                Divider()
                DeviceInfoRow(
                    name: "Build Date",
                    value: firmwareBuild
                )
                .padding(.horizontal, 12)

                Divider()
                DeviceInfoRow(
                    name: "Int. Flash (Used/Total)",
                    value: internalSpace
                )
                .padding(.horizontal, 12)

                Divider()
                DeviceInfoRow(
                    name: "SD Card (Used/Total)",
                    value: externalSpace
                )
                .padding(.horizontal, 12)

                HStack {
                    Text("Full info")
                    Image(systemName: "chevron.right")
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.black16)
                .padding(.top, 6)
            }
            .padding(.bottom, 12)
        }
        .foregroundColor(.primary)
        .background(Color.groupedBackground)
        .cornerRadius(10)
    }
}
