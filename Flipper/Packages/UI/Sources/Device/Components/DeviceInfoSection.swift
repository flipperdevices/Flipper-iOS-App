import Core
import Peripheral
import SwiftUI

struct DeviceInfoSection: View {
    let device: Flipper?

    var isConnected: Bool {
        device?.state == .connected
    }

    var _protobufVersion: ProtobufVersion? {
        device?.information?.protobufRevision
    }

    var protobufVersion: String {
        guard isConnected else { return "—" }
        guard let version = _protobufVersion else { return "" }
        return version == .unknown ? "—" : version.rawValue
    }

    var firmwareVersion: String {
        guard isConnected else { return "—" }
        guard let info = device?.information else { return "" }

        let version = info
            .softwareRevision
            .split(separator: " ")
            .dropFirst()
            .prefix(1)
            .joined()

        return .init(version)
    }

    var firmwareBuild: String {
        guard isConnected else { return "—" }
        guard let info = device?.information else { return "" }

        let build = info
            .softwareRevision
            .split(separator: " ")
            .suffix(1)
            .joined(separator: " ")

        return .init(build)
    }

    var internalSpace: String {
        guard isConnected else { return "—" }
        return device?.storage?.internal?.description ?? ""
    }

    var externalSpace: String {
        guard isConnected else { return "—" }
        return device?.storage?.external?.description ?? ""
    }

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

                if isConnected {
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
        .foregroundColor(.primary)
        .background(Color.groupedBackground)
        .cornerRadius(10)
    }
}

extension StorageSpace: CustomStringConvertible {
    public var description: String {
        "\(used.hr) / \(total.hr)"
    }
}

fileprivate extension Int {
    var hr: String {
        let formatter = ByteCountFormatter()
        return formatter.string(fromByteCount: Int64(self))
    }
}
