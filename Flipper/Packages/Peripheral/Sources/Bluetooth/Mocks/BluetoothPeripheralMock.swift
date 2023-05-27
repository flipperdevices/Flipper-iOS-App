import Combine
import Foundation

class BluetoothPeripheralMock: BluetoothPeripheral {
    var id: UUID
    var name: String
    var color: FlipperColor
    var state: FlipperState = .disconnected

    var services: [FlipperService] = [
        .init(
            name: .deviceInformation,
            characteristics: [
                .init(name: .manufacturerName, value: .init("Flipper".utf8)),
                .init(name: .serialNumber, value: .init("Serial".utf8)),
                .init(name: .firmwareRevision, value: .init("Firmware".utf8)),
                .init(name: .softwareRevision, value: .init("Software".utf8)),
                .init(name: .protobufUUID, value: .init("0.11".utf8))
            ]),
        .init(
            name: .battery,
            characteristics: [
                .init(name: "Level", value: [100])
            ])
    ]

    var isPairingFailed: Bool { false }
    var didDiscoverDeviceInformation: Bool { true }
    var maximumWriteValueLength: Int { 512 }

    var info: AnyPublisher<Void, Never> {
        infoSubject.eraseToAnyPublisher()
    }

    var canWrite: AnyPublisher<Void, Never> {
        canWriteSubject.eraseToAnyPublisher()
    }

    var received: AnyPublisher<Data, Never> {
        receivedDataSubject.eraseToAnyPublisher()
    }

    fileprivate let infoSubject = PassthroughSubject<Void, Never>()
    fileprivate let canWriteSubject = PassthroughSubject<Void, Never>()
    fileprivate let receivedDataSubject = PassthroughSubject<Data, Never>()

    init(
        id: UUID = .init(),
        name: String = "FlipMock",
        color: FlipperColor = .unknown
    ) {
        self.id = id
        self.name = name
        self.color = color
    }

    func onConnecting() {
        print("on connecting")
    }

    func onConnect() {
        print("on connect")
    }

    func onDisconnect() {
        print("on disconnect")
    }

    func onError(_ error: Swift.Error) {
        print("on error", error)
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
    static var protobufUUID: String { "03F6666D-AE5E-47C8-8E1A-5D873EB5A933" }
}
