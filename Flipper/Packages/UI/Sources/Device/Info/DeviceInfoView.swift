import Core
import Collections
import SwiftUI

struct DeviceInfoView: View {
    @EnvironmentObject var device: Device
    @Environment(\.dismiss) private var dismiss

    var deviceInfo: [String: String] {
        device.deviceInfo
    }

    var powerInfo: [String: String] {
        device.powerInfo
    }

    var deviceName: String {
        deviceInfo["hardware_name"] ?? ""
    }
    var hardwareModel: String {
        deviceInfo["hardware_model"] ?? ""
    }
    var hardwareRegion: String {
        deviceInfo["hardware_region"] ?? ""
    }
    var hardwareRegionProvisioned: String {
        deviceInfo["hardware_region_provisioned"] ?? ""
    }

    var hardwareVersion: String { deviceInfo["hardware_ver"] ?? "" }
    var hardwareOTPVersion: String { deviceInfo["hardware_otp_ver"] ?? "" }
    var serialNumber: String { deviceInfo["hardware_uid"] ?? "" }

    var softwareRevision: String { deviceInfo["firmware_commit"] ?? "" }
    var buildDate: String { deviceInfo["firmware_build_date"] ?? "" }
    var firmwareTarget: String { deviceInfo["firmware_target"] ?? "" }
    var protobufVersion: String {
        guard
            let major = deviceInfo["protobuf_version_major"],
            let minor = deviceInfo["protobuf_version_minor"]
        else {
            return ""
        }
        return "\(major).\(minor)"
    }

    var radioFirmware: String {
        guard
            let major = deviceInfo["radio_stack_major"],
            let minor = deviceInfo["radio_stack_minor"],
            let type = deviceInfo["radio_stack_type"]
        else {
            return ""
        }
        let typeString = RadioStackType(rawValue: type)?.description
            ?? "Unknown"
        return "\(major).\(minor).\(type) (\(typeString))"
    }

    private var usedKeys: [String] = [
        "hardware_name",
        "hardware_model",
        "hardware_region",
        "hardware_region_provisioned",
        "hardware_ver",
        "hardware_otp_ver",
        "hardware_uid",
        "firmware_commit",
        "firmware_build_date",
        "firmware_target",
        "protobuf_version_major",
        "protobuf_version_minor",
        "radio_stack_major",
        "radio_stack_minor",
        "radio_stack_type"
    ]

    private func formatKey(_ key: String) -> String {
        key
            .replacingOccurrences(of: "_", with: " ")
            .capitalized
            .replacingOccurrences(of: "Ble", with: "BLE")
            .replacingOccurrences(of: "Fus", with: "FUS")
            .replacingOccurrences(of: "Sram", with: "SRAM")
    }

    var otherKeys: OrderedDictionary<String, String> {
        var result: OrderedDictionary<String, String> = .init()

        let keys = deviceInfo.keys
            .filter { !usedKeys.contains($0) }
            .sorted()

        for key in keys {
            result[formatKey(key)] = deviceInfo[key]
        }

        return result
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                DeviceInfoViewCard(
                    title: "Flipper Device",
                    values: [
                        "Device Name": deviceName,
                        "Hardware Model": hardwareModel,
                        "Hardware Region": hardwareRegion,
                        "Hardware Region Provisioned":
                            hardwareRegionProvisioned,
                        "Hardware Version": hardwareVersion,
                        "Hardware OTP Version": hardwareOTPVersion,
                        "Serial Number": serialNumber
                    ]
                )

                DeviceInfoViewCard(
                    title: "Firmware",
                    values: [
                        "Software Revision": softwareRevision,
                        "Build Date": buildDate,
                        "Target": firmwareTarget,
                        "Protobuf Version": protobufVersion
                    ]
                )

                DeviceInfoViewCard(
                    title: "Radio Stack",
                    values: [
                        "Radio Firmware": radioFirmware
                    ]
                )

                DeviceInfoViewCard(
                    title: "Other",
                    values: otherKeys
                )
            }
            .textSelection(.enabled)
            .padding(.vertical, 14)
        }
        .background(Color.background)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            LeadingToolbarItems {
                BackButton {
                    dismiss()
                }
                Title("Device Info")
            }
            TrailingToolbarItems {
                ShareButton {
                    share()
                }
                .disabled(!device.isInfoReady)
                .opacity(device.isInfoReady ? 1 : 0.4)
            }
        }
        .task {
            await device.getInfo()
        }
    }

    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        return formatter
    }()

    private func share() {
        var array = deviceInfo.toArray().sorted()
        array += powerInfo.toArray().sorted()

        if let int = device.flipper?.storage?.internal {
            array.append("int_available: \(int.free)")
            array.append("int_total: \(int.total)")
        }
        if let ext = device.flipper?.storage?.external {
            array.append("ext_available: \(ext.free)")
            array.append("ext_total: \(ext.total)")
        }

        let name = device.flipper?.name ?? "unknown"
        let content = array.joined(separator: "\n")
        let filename = "dump-\(name)-\(formatter.string(from: Date())).txt"
        
        UI.shareFile(name: filename, content: content)
    }
}

private extension Dictionary where Key == String, Value == String {
    func toArray() -> [String] {
        self.map { "\($0): \($1)" }
    }
}
