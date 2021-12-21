import Foundation

class BluetoothPeripheralMock: BluetoothPeripheral {
    var id: UUID
    var name: String
    var color: Peripheral.Color

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

    var maximumWriteValueLength: Int { 512 }

    var info: SafePublisher<Void> {
        infoSubject.eraseToAnyPublisher()
    }

    var canWrite: SafePublisher<Void> {
        canWriteSubject.eraseToAnyPublisher()
    }

    var received: SafePublisher<Data> {
        receivedDataSubject.eraseToAnyPublisher()
    }

    fileprivate let infoSubject = SafeSubject<Void>()
    fileprivate let canWriteSubject = SafeSubject<Void>()
    fileprivate let receivedDataSubject = SafeSubject<Data>()

    init(
        id: UUID = .init(),
        name: String = "FlipMock",
        color: Peripheral.Color = .unknown
    ) {
        self.id = id
        self.name = name
        self.color = color
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
