import Core
import SwiftUI

public struct DeviceView: View {
    @StateObject var viewModel: DeviceViewModel
    @State private var action: String?

    public var body: some View {
        NavigationView {
            VStack {
                DeviceViewHeader(
                    status: viewModel.status,
                    displayingConnections: $viewModel.presentConnectionsSheet)

                ScrollView {
                    VStack {
                        if let device = viewModel.device {
                            DeviceImageNameModelBattery(device: device)
                                .padding(.vertical, 26)
                                .padding(.horizontal, 15)
                        } else {
                            Text("Connect your Flipper")
                                .font(.system(size: 26))
                                .padding(.vertical, 50)
                                .multilineTextAlignment(.center)
                        }

                        NavigationLink {
                            DeviceInfoView(viewModel: .init())
                        } label: {
                            DeviceInfoPreview(
                                firmwareVersion: viewModel.firmwareVersion,
                                firmwareBuild: viewModel.firmwareBuild)
                        }

                        RoundedButton("Synchronize") {
                            viewModel.sync()
                        }
                        .disabled(viewModel.status == .synchronizing)
                        .padding(.top, 12)
                        .padding(.bottom, 24)
                    }
                    .background(systemBackground)
                    .disabled(viewModel.device?.state != .connected)

                    ActionsForm(actions: actions) { id in
                        self.action = id
                    }
                    .padding(.top, 20)
                    .disabled(viewModel.device?.state != .connected)

                    NavigationLink("", tag: fileManager.name, selection: $action) {
                        StorageView(viewModel: .init())
                    }
                    NavigationLink("", tag: remoteControl.name, selection: $action) {
                        RemoteContolView(viewModel: .init())
                    }
                }
                .background(Color.gray.opacity(0.1))
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $viewModel.presentConnectionsSheet) {
                ConnectionsView(viewModel: .init())
                Spacer()
                Button("Skip connection") {
                    viewModel.presentConnectionsSheet = false
                }
                .padding(.bottom, onMac ? 140 : 16)
            }
        }
    }
}

extension DeviceView {
    struct Action: ActionProtocol {
        var id: String { name }

        let name: String
        let image: Image
    }

    var actions: [Action] {
        [runApps, remoteControl, fileManager]
    }

    var runApps: Action {
        .init(name: "Run Apps", image: .init(systemName: "play.circle"))
    }

    var remoteControl: Action {
        .init(
            name: "Remote Control",
            image: .init(systemName: "appletvremote.gen1")
        )
    }

    var fileManager: Action {
        .init(name: "File manager", image: .init(systemName: "folder.circle"))
    }
}

struct DeviceViewHeader: View {
    let status: Status
    @Binding var displayingConnections: Bool

    var body: some View {
        HeaderView(
            status: status,
            leftView: {
                Button {
                    displayingConnections = true
                } label: {
                    Image("BluetoothOn")
                        .headerImageStyle()
                        .frame(width: 20, height: 20)
                        .overlay(
                            Circle()
                                .stroke(.blue, lineWidth: 1.5)
                        )
                }
                .padding(.leading, 5)
            },
            rightView: {
                Image(systemName: "gamecontroller")
                    .headerImageStyle()
                    .frame(width: 20, height: 20)
                    .opacity(0)
            })
    }
}

struct DeviceInfoPreview: View {
    let firmwareVersion: String
    let firmwareBuild: String

    var body: some View {
        VStack {
            HStack {
                Text("Device Info")
                    .font(.system(size: 20, weight: .semibold))
                Spacer()
                Image(systemName: "chevron.right")
            }

            VStack {
                DeviceInfoRow(name: "Firmware Version", value: firmwareVersion)
                Divider()
                DeviceInfoRow(name: "Firmware Build", value: firmwareBuild)
                Divider()
            }
            .padding(.vertical, 12)
        }
        .padding(.horizontal, 16)
        .foregroundColor(.primary)
    }
}

struct DeviceInfoRow: View {
    let name: String
    let value: String?

    var body: some View {
        HStack {
            Text("\(name)")
                .font(.system(size: 16, weight: .light))
                .foregroundColor(.secondary)
            Spacer()
            Text("\(value ?? .unknown.lowercased())")
                .font(.system(size: 16, weight: .light))
                .multilineTextAlignment(.trailing)
        }
    }
}

struct DeviceImageNameModelBattery: View {
    let device: Peripheral

    var batteryColor: Color {
        guard let battery = device.battery else {
            return .clear
        }
        switch battery.decimalValue * 100 {
        case 0..<20: return .red
        case 20..<50: return .yellow
        case 50...100: return .green
        default: return .clear
        }
    }

    var body: some View {
        HStack {
            Image("FlipperWhite")
                .resizable()
                .scaledToFit()

            VStack(alignment: .leading, spacing: 10) {
                Text(device.name)
                    .font(.system(size: 22, weight: .semibold))

                Text("Flipper Zero")
                    .font(.system(size: 18, weight: .light))
                    .foregroundColor(.gray)

                HStack(alignment: .top, spacing: 6) {
                    if let battery = device.battery {
                        ZStack(alignment: .topLeading) {
                            Image("Battery")

                            RoundedRectangle(cornerRadius: 1)
                                .frame(
                                    width: 18 * battery.decimalValue,
                                    height: 7)
                                .padding(.top, 3)
                                .padding(.leading, 6)
                                .foregroundColor(batteryColor)
                        }
                        .padding(.top, 2)
                    }

                    if let battery = device.battery {
                        Text("\(battery.level.value) %")
                            .font(.system(size: 14, weight: .semibold))
                    }
                }
                .frame(height: 21)
            }
            .padding(.leading, 8)
            .padding(.trailing, 36)
        }
        .frame(maxWidth: .infinity)
    }
}

struct DeviceView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceView(viewModel: .init())
    }
}
