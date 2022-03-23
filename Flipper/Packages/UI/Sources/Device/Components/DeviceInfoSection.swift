import SwiftUI

struct DeviceInfoSection: View {
    let protobufVersion: String?
    let firmwareVersion: String
    let firmwareBuild: String
    let internalSpace: String?
    let externalSpace: String?

    var body: some View {
        VStack {
            HStack {
                Text("Device Info")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
            }
            .padding(.top, 12)

            VStack {
                if let protobufVersion = protobufVersion {
                    DeviceInfoRow(
                        name: "Protobuf Version",
                        value: protobufVersion)
                    Divider()
                }
                DeviceInfoRow(
                    name: "Firmware Version",
                    value: firmwareVersion)
                Divider()
                DeviceInfoRow(
                    name: "Firmware Build",
                    value: firmwareBuild)

                if let internalSpace = internalSpace {
                    Divider()
                    DeviceInfoRow(
                        name: "Internal Flash (Free/Total)",
                        value: internalSpace)
                }

                if let externalSpace = externalSpace {
                    Divider()
                    DeviceInfoRow(
                        name: "SD Card (Free/Total)",
                        value: externalSpace)
                }

                HStack {
                    Text("Full info")
                    Image(systemName: "chevron.right")
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.black16)
                .padding(.top, 6)
            }
            .padding(.vertical, 12)
        }
        .padding(.horizontal, 16)
        .foregroundColor(.primary)
        .background(Color.groupedBackground)
        .cornerRadius(10)
    }
}