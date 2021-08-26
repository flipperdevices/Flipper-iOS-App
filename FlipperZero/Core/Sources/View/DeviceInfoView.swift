import SwiftUI

struct DeviceInfoView: View {
    @ObservedObject var viewModel: DeviceInfoViewModel = .init()

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
