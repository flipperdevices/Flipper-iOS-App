import SwiftUI

struct ConnectionsView: View {
    @StateObject var viewModel: ConnectionsViewModel

    var body: some View {
        NavigationView {
            VStack {
                switch self.viewModel.state {
                case .notReady(let reason):
                    Text(reason.description)
                        .multilineTextAlignment(.center)
                        .padding(.all)
                    if reason == .unauthorized {
                        Button("Open Settings") {
                            viewModel.openApplicationSettings()
                        }
                    }
                case .ready:
                    Text("Scanning devices...")
                        .font(.title)
                        .padding(.all)
                    Form {
                        Section(header: HStack {
                            Text("devices")
                            ProgressView()
                                .padding(.horizontal, 3)
                        }) {
                            List(viewModel.peripherals) { peripheral in
                                row(for: peripheral)
                            }
                        }
                    }
                }
            }
            .frame(minWidth: 320, minHeight: 160)
        }
    }

    func row(for peripheral: Peripheral) -> some View {
        HStack {
            Button(peripheral.name) {
                if peripheral.state != .connected {
                    viewModel.connect(to: peripheral.id)
                }
            }.foregroundColor(.primary)

            Spacer()

            if peripheral.state == .connecting {
                ProgressView()
            } else if peripheral.state == .connected {
                Text("Connected")
                    .foregroundColor(.secondary)
            }
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
        var state: CBPeripheralState = .disconnected
        var services: [CBService] = []

        func send(_ request: Request) {}

        var info: SafePublisher<Void> { Just(()).eraseToAnyPublisher() }
        var received: SafePublisher<Response> { Just(.ping).eraseToAnyPublisher() }
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
