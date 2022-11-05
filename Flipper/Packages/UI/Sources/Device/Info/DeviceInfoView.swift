import Core
import Collections
import SwiftUI

struct DeviceInfoView: View {
    @StateObject var viewModel: DeviceInfoViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                DeviceInfoViewCard(
                    title: "Flipper Device",
                    values: [
                        "Device Name": viewModel.deviceName,
                        "Hardware Model": viewModel.hardwareModel,
                        "Hardware Region": viewModel.hardwareRegion,
                        "Hardware Region Provisioned":
                            viewModel.hardwareRegionProvisioned,
                        "Hardware Version": viewModel.hardwareVersion,
                        "Hardware OTP Version": viewModel.hardwareOTPVersion,
                        "Serial Number": viewModel.serialNumber
                    ]
                )

                DeviceInfoViewCard(
                    title: "Firmware",
                    values: [
                        "Software Revision": viewModel.softwareRevision,
                        "Build Date": viewModel.buildDate,
                        "Target": viewModel.firmwareTarget,
                        "Protobuf Version": viewModel.protobufVersion
                    ]
                )

                DeviceInfoViewCard(
                    title: "Radio Stack",
                    values: [
                        "Radio Firmware": viewModel.radioFirmware
                    ]
                )

                DeviceInfoViewCard(
                    title: "Other",
                    values: viewModel.otherKeys
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
                    viewModel.share()
                }
                .disabled(!viewModel.isReady)
                .opacity(viewModel.isReady ? 1 : 0.4)
            }
        }
        .task {
            await viewModel.getInfo()
        }
    }
}

struct DeviceInfoViewCard: View {
    let title: String
    var values: OrderedDictionary<String, String>

    var zippedIndexKey: [(Int, String)] {
        .init(zip(values.keys.indices, values.keys))
    }

    var body: some View {
        Card {
            VStack(spacing: 12) {
                HStack {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                    Spacer()
                }
                .padding(.bottom, 6)
                .padding(.horizontal, 12)

                ForEach(zippedIndexKey, id: \.0) { index, key in
                    CardRow(name: key, value: values[key] ?? "")
                        .padding(.horizontal, 12)
                    if index + 1 < values.count {
                        Divider()
                    }
                }
            }
            .padding(.vertical, 12)
        }
        .padding(.horizontal, 14)
    }
}
