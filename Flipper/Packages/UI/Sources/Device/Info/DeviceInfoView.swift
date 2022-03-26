import Core
import SwiftUI

struct DeviceInfoView: View {
    @StateObject var viewModel: DeviceInfoViewModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            Form {
                if let deviceInformation = viewModel.device?.information {
                    DeviceInformationService(deviceInformation)
                }

                DeviceInformation(viewModel.deviceInfo)
            }
        }
        .navigationTitle("Device Info")
        .onAppear {
            viewModel.getDeviceInfo()
        }
    }
}

struct DeviceInformationService: View {
    let deviceInformation: Peripheral.DeviceInformation

    init(_ deviceInformation: Peripheral.DeviceInformation) {
        self.deviceInformation = deviceInformation
    }

    var body: some View {
        Section(header: Text("Device Information (GATT)")) {
            SectionRow(
                name: "Manufacturer Name",
                value: deviceInformation.manufacturerName)

            SectionRow(
                name: "Serial Number",
                value: deviceInformation.serialNumber)

            SectionRow(
                name: "Firmware Revision",
                value: deviceInformation.firmwareRevision)

            SectionRow(
                name: "Software Revision",
                value: deviceInformation.softwareRevision)

            SectionRow(
                name: "Protobuf Revision",
                value: deviceInformation.protobufRevision)
        }
    }
}

struct DeviceInformation: View {
    let deviceInformation: [String: String]

    init(_ deviceInformation: [String: String]) {
        self.deviceInformation = deviceInformation
    }

    var body: some View {
        Section {
            ForEach([String](deviceInformation.keys), id: \.self) { key in
                SectionRow(name: key, value: deviceInformation[key] ?? "")
            }
        } header: {
            HStack(spacing: 8) {
                Text("Device Information (RPC)")
                ProgressView()
                    .opacity(deviceInformation.isEmpty ? 1 : 0)
                Spacer()
            }
        }
    }
}

struct SectionRow: View {
    let name: String
    let value: String

    var body: some View {
        HStack {
            Text("\(name)")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.black30)
            Spacer()
            Text("\(value)")
                .font(.system(size: 14, weight: .regular))
                .multilineTextAlignment(.trailing)
        }
    }
}
