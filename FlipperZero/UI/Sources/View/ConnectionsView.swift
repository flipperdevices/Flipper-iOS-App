import Combine
import SwiftUI

// swiftlint:disable closure_body_length

struct ConnectionsView: View {
    @ObservedObject var viewModel: ConnectionsViewModel

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
                case .scanning(let peripherals):
                    Text("Scanning devices...")
                        .font(.title)
                        .padding(.all)
                    Form {
                        Section(header: HStack {
                            Text("devices")
                            ProgressView()
                                .padding(.horizontal, 3)
                        }) {
                            List(peripherals) { peripheral in
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
import Injector

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
        Container.shared.register(instance: TestConnector(status), as: BluetoothConnector.self)
        return .init()
    }
}

private class TestConnector: BluetoothConnector {
    private let peripheralsSubject = SafeSubject([Peripheral]())
    private let connectedPeripheralSubject = SafeSubject(Peripheral?.none)
    private let statusValue: BluetoothStatus
    private var timer: Timer?
    private let testDevices = Array(1...10).map {
        Peripheral(id: UUID(), name: "Device \($0)")
    }

    var peripherals: SafePublisher<[Peripheral]> {
        self.peripheralsSubject.eraseToAnyPublisher()
    }

    var connectedPeripheral: SafePublisher<Peripheral?> {
        self.connectedPeripheralSubject.eraseToAnyPublisher()
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
    func forget(about uuid: UUID) {}

    // TODO: Refactor

    func send(_ bytes: [UInt8]) {}
    let receivedSubject = SafeSubject([UInt8]())
    var received: SafePublisher<[UInt8]> {
        receivedSubject.eraseToAnyPublisher()
    }
}
