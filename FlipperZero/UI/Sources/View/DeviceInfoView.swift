import SwiftUI

struct DeviceInfoView: View {
    @ObservedObject var viewModel: DeviceInfoViewModel = .init()

    init(viewModel: DeviceInfoViewModel = .init()) {
        self.viewModel = viewModel
    }

    var body: some View {
        if let device = viewModel.device {
            VStack {
                Spacer()
                Form {
                    ForEach(device.services) { service in
                        Section(header: Text(service.name)) {
                            List(service.characteristics) { characteristic in
                                HStack {
                                    Text("\(characteristic.name)")
                                    Spacer()
                                    Text("\(characteristic.value)")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    Button("Forget This Device") {
                        viewModel.forgetConnectedDevice()
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
