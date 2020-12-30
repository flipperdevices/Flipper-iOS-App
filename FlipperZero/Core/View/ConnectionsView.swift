//
//  ConnectionsView.swift
//  FlipperZero
//
//  Created by Eugene Berdnikov on 8/29/20.
//

import Combine
import SwiftUI

struct ConnectionsView: View {
    @ObservedObject var viewModel: ConnectionsViewModel

    var body: some View {
        VStack {
            switch self.viewModel.state {
            case .notReady(let reason):
                Text(reason)
                    .multilineTextAlignment(.center)
                    .padding(.all)
            case .scanning(let peripherals):
                HStack {
                    Text("Scanning devices...")
                        .font(.title)
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding(.horizontal)
                }
                    .padding(.all)
                List(peripherals) { peripheral in
                    Text(peripheral.name)
                }
            }
        }
        .frame(minWidth: 320, minHeight: 160)
    }
}

struct ConnectionsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ConnectionsView(viewModel: ConnectionsViewModel(self.getContainer(.ready)))
            ConnectionsView(viewModel: ConnectionsViewModel(self.getContainer(.notReady(.poweredOff))))
            ConnectionsView(viewModel: ConnectionsViewModel(self.getContainer(.notReady(.preparing))))
            ConnectionsView(viewModel: ConnectionsViewModel(self.getContainer(.notReady(.unauthorized))))
            ConnectionsView(viewModel: ConnectionsViewModel(self.getContainer(.notReady(.unsupported))))
        }
    }

    private static func getContainer(_ status: BluetoothStatus) -> Resolver {
        let container = Container()
        container.register(instance: TestConnector(status), as: BluetoothConnector.self)
        return container
    }
}

private class TestConnector: BluetoothConnector {
    private let peripheralsSubject = SafeSubject([Peripheral]())
    private let statusValue: BluetoothStatus
    private var timer: Timer?
    private let testDevices = Array(1...10).map {
        Peripheral(id: UUID(), name: "Device \($0)")
    }

    var peripherals: SafePublisher<[Peripheral]> {
        self.peripheralsSubject.eraseToAnyPublisher()
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
}
