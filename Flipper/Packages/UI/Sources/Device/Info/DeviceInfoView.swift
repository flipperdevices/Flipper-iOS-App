import Core
import Collections
import SwiftUI

struct DeviceInfoView: View {
    @EnvironmentObject var device: Device
    @Environment(\.dismiss) private var dismiss

    var info: Device.Info { device.info }
    var hardware: Device.Info.Hardware { info.hardware }
    var firmware: Device.Info.Firmware { info.firmware }

    var deviceName: String? { hardware.name }
    var hardwareModel: String? { hardware.model }
    var hardwareRegion: String? { hardware.region.builtin }
    var hardwareRegionProvisioned: String? { hardware.region.provisioned }

    var hardwareVersion: String? { hardware.version }
    var hardwareOTPVersion: String? { info.hardware.otp.version }
    var serialNumber: String? { hardware.uid }

    var softwareRevision: String? { firmware.formatted }
    var buildDate: String? { firmware.build.date }
    var firmwareTarget: String? { firmware.target }
    var protobufVersion: String? { info.protobuf.version.formatted }

    var radioFirmware: String? { info.radio.stack.formatted }

    var otherKeys: OrderedDictionary<String, String?> {
        var result: OrderedDictionary<String, String?> = .init()

        for key in info.unknown.keys.sorted() {
            result[key] = info.unknown[key]
        }

        return result
    }

    var canRefresh: Bool {
        device.status == .connected && device.isInfoReady == true
    }

    var body: some View {
        RefreshableScrollView(isEnabled: canRefresh) {
            reload()
        } content: {
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
            reload()
        }
    }

    private func reload() {
        Task {
            await device.getInfo()
        }
    }

    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        return formatter
    }()

    private func share() {
        var array = info.keys.toArray().sorted()

        if let int = device.flipper?.storage?.internal {
            array.append("storage.int.available: \(int.free)")
            array.append("storage.int.total: \(int.total)")
        }
        if let ext = device.flipper?.storage?.external {
            array.append("storage.ext.available: \(ext.free)")
            array.append("storage.ext.total: \(ext.total)")
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
