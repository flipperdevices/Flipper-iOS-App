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

import Core
import Combine
import Injector
import CoreBluetooth

struct ConnectionsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ConnectionsView(viewModel: createObject(.ready))
            ConnectionsView(viewModel: createObject(.notReady(.poweredOff)))
            ConnectionsView(viewModel: createObject(.notReady(.preparing)))
            ConnectionsView(viewModel: createObject(.notReady(.unauthorized)))
            ConnectionsView(viewModel: createObject(.notReady(.unsupported)))
        }
    }

    private static func createObject(_ status: BluetoothStatus) -> ConnectionsViewModel {
        Container.shared.register(instance: TestConnector(status), as: BluetoothCentral.self)
        Container.shared.register(instance: TestConnector(status), as: BluetoothConnector.self)
        return .init()
    }
}

private class TestConnector: BluetoothCentral, BluetoothConnector {
    private struct TestPeripheral: BluetoothPeripheral {
        var id: UUID
        var name: String
        var state: Peripheral.State = .disconnected
        var services: [CBService] = []

        var info: SafePublisher<Void> { Just(()).eraseToAnyPublisher() }
        var screenFrame: SafePublisher<ScreenFrame> { Just(.init([])).eraseToAnyPublisher() }

        func send(_ request: Request, priority: Priority?) async throws -> Response {
            .ok
        }
    }

    private let peripheralsSubject = SafeValueSubject([BluetoothPeripheral]())
    private let connectedPeripheralsSubject = SafeValueSubject([BluetoothPeripheral]())
    private let statusValue: BluetoothStatus
    private var timer: Timer?
    private let testDevices = Array(1...10).map {
        TestPeripheral(id: UUID(), name: "Device \($0)")
    }

    var peripherals: SafePublisher<[BluetoothPeripheral]> {
        self.peripheralsSubject.eraseToAnyPublisher()
    }

    var connectedPeripherals: SafePublisher<[BluetoothPeripheral]> {
        self.connectedPeripheralsSubject.eraseToAnyPublisher()
    }

    var status: SafePublisher<BluetoothStatus> {
        Just(self.statusValue).eraseToAnyPublisher()
    }

    init(_ status: BluetoothStatus) {
        self.statusValue = status
        if case .ready = status {
            self.startScanForPeripherals()
        }
    }

    func startScanForPeripherals() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let `self` = self else {
                return
            }

            let index = Int.random(in: -self.peripheralsSubject.value.count..<self.testDevices.count)
            if index < 0 {
                self.peripheralsSubject.value.remove(at: -1 - index)
            } else {
                self.peripheralsSubject.value.append(self.testDevices[index])
            }
        }
    }

    func stopScanForPeripherals() {
        self.timer?.invalidate()
        self.timer = nil
        self.peripheralsSubject.value.removeAll()
    }

    func connect(to uuid: UUID) {}
    func disconnect(from uuid: UUID) {}
}
