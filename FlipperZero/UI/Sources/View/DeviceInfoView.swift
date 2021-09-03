import SwiftUI

struct DeviceInfoView: View {
    @ObservedObject var viewModel: DeviceInfoViewModel = .init()
    let showDeviceInfo: Binding<Bool>?

    init(viewModel: DeviceInfoViewModel = .init(), showDeviceInfo: Binding<Bool>? = nil) {
        self.viewModel = viewModel
        self.showDeviceInfo = showDeviceInfo
    }

    var body: some View {
        if let device = viewModel.device {
            VStack {
                Spacer()
                ForEach(device.services) { service in
                    Form {
                        Section(header: Text("About")) {
                            List(service.characteristics) { characteristic in
                                HStack {
                                    Text("\(characteristic.name)")
                                    Spacer()
                                    Text("\(characteristic.value)")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        Button("Forget This Device") {
                            viewModel.forgetConnectedDevice()
                            showDeviceInfo?.wrappedValue = false
                        }
                    }
                }
            }
        } else {
            Text("No device connected")
        }
    }
}

struct DeviceInfoView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceInfoView(viewModel: .init())
    }
}
