import Foundation
@testable import Core

class BluetoothPeripheralMock: BluetoothPeripheral {
    weak var delegate: PeripheralDelegate?

    var id: UUID
    var name: String

    var state: Peripheral.State = .disconnected

    var services: [Peripheral.Service] = [
        .init(
            name: .deviceInformation,
            characteristics: [
                .init(name: .manufacturerName, value: .init("Flipper".utf8)),
                .init(name: .serialNumber, value: .init("Serial".utf8)),
                .init(name: .firmwareRevision, value: .init("Firmware".utf8)),
                .init(name: .softwareRevision, value: .init("Software".utf8))
            ]),
        .init(
            name: .battery,
            characteristics: [
                .init(name: "Level", value: [100])
            ])
    ]

    var info: SafePublisher<Void> {
        infoSubject.eraseToAnyPublisher()
    }

    fileprivate let infoSubject = SafeSubject<Void>()

    init(id: UUID = .init(), name: String = "FlipMock") {
        self.id = id
        self.name = name
    }

    func onConnect() {
        print("on connect")
    }

    func onDisconnect() {
        print("on disconnect")
    }

    func onFailToConnect() {
        print("on fail to connect")
    }

    func send(_ data: Data) {
        print("send data")
    }
}

fileprivate extension String {
    static var deviceInformation: String { "Device Information" }
    static var battery: String { "Battery" }
}

fileprivate extension String {
    static var manufacturerName: String { "Manufacturer Name String" }
    static var serialNumber: String { "Serial Number String" }
    static var firmwareRevision: String { "Firmware Revision String" }
    static var softwareRevision: String { "Software Revision String" }
}
