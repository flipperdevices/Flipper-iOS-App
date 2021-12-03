import Core
import SwiftUI

struct ConnectionsView: View {
    @StateObject var viewModel: ConnectionsViewModel

    var body: some View {
        VStack {
            switch self.viewModel.state {
            case .notReady(let reason):
                Text("Bluetooth access")
                    .font(.system(size: 32, weight: .bold))
                    .padding(.top, 66)
                Spacer()
                Image("DolphinSign")
                Text(reason.description)
                    .multilineTextAlignment(.center)
                    .padding(25)
                if reason == .unauthorized {
                    Button("Open Settings") {
                        viewModel.openApplicationSettings()
                    }
                }
                Spacer()
            case .ready:
                Text("Choose your Flipper")
                    .font(.system(size: 32, weight: .bold))
                    .padding(.top, 50)

                HStack(spacing: 12) {
                    Text("Searching")
                    ProgressView()
                    Spacer()
                }
                .padding(.vertical, 23)

                ForEach(viewModel.peripherals) { peripheral in
                    row(for: peripheral)
                }
            }
        }
        .padding(.horizontal, 16)
        .onDisappear {
            viewModel.stopScan()
        }
    }

    func row(for peripheral: Peripheral) -> some View {
        HStack {
            HStack {
                Image("BluetoothOn")
                    .resizable()
                    .frame(width: 13, height: 20)

                Text(peripheral.name)
                    .foregroundColor(.accentColor)

                Spacer()

                switch peripheral.state {
                case .connecting:
                    ProgressView()
                case .connected:
                    Text("Connected")
                        .foregroundColor(.secondary)
                default:
                    ConnectButton("Connect") {
                        if peripheral.state != .connected {
                            viewModel.connect(to: peripheral.id)
                        }
                    }
                }
            }
            .padding(.horizontal, 14)
        }
        .frame(height: 52)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

// TODO: Use RoundedButton or iOS15 buttons

struct ConnectButton: View {
    let text: String
    let action: () -> Void

    init(_ text: String, action: @escaping () -> Void) {
        self.text = text
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 13, weight: .medium))
                .padding(.vertical, 5)
                .padding(.horizontal, 14)
                .background(Color.accentColor)
                .foregroundColor(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 7))
        }
    }
}
