import Core
import SwiftUI

struct DeviceInfoView: View {
    @StateObject var viewModel: DeviceInfoViewModel

    var body: some View {
        VStack {
            Form {
                Section(header: Text("General")) {
                    SectionRow(name: "Name", value: viewModel.name)
                    SectionRow(name: "UUID", value: viewModel.uuid)
                }
                if let deviceInformation = viewModel.device?.information {
                    DeviceInformationService(deviceInformation)
                }
                if let battery = viewModel.device.battery {
                    BatteryService(battery)
                }
                Button {
                    viewModel.forgetConnectedDevice()
                } label: {
                    HStack {
                        Spacer()
                        Text("Disconnect Flipper")
                        Spacer()
                    }
                    .disabled(viewModel.device?.state != .connected)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

struct DeviceInformationService: View {
    let deviceInformation: Peripheral.Service.DeviceInformation

    init(_ deviceInformation: Peripheral.Service.DeviceInformation) {
        self.deviceInformation = deviceInformation
    }

    var body: some View {
        Section(header: Text("Device Information")) {
            CharacteristicSectionRow(deviceInformation.manufacturerName)
            CharacteristicSectionRow(deviceInformation.serialNumber)
            CharacteristicSectionRow(deviceInformation.firmwareRevision)
            CharacteristicSectionRow(deviceInformation.softwareRevision)
        }
    }
}

struct BatteryService: View {
    let battery: Peripheral.Service.Battery

    init(_ battery: Peripheral.Service.Battery) {
        self.battery = battery
    }

    var body: some View {
        Section(header: Text("Battery")) {
            CharacteristicSectionRow(battery.level)
        }
    }
}

struct CharacteristicSectionRow: View {
    let characteristic: Peripheral.Service.Characteristic

    init(_ characteristic: Peripheral.Service.Characteristic) {
        self.characteristic = characteristic
    }

    var body: some View {
        SectionRow(name: characteristic.name, value: characteristic.value)
    }
}

struct SectionRow: View {
    let name: String
    let value: String

    var body: some View {
        HStack {
            Text("\(name)")
            Spacer()
            Text("\(value)")
                .multilineTextAlignment(.trailing)
                .foregroundColor(.secondary)
        }
    }
}

struct DeviceInfoView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceInfoView(viewModel: .init())
    }
}
