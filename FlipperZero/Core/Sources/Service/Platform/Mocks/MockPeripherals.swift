import Foundation
import CoreBluetoothMock

// MARK: - Mock Flipper Zero

public func registerMocks() {
    CBMCentralManagerMock.simulatePeripherals([flipper])
    CBMCentralManagerMock.simulatePowerOn()
}

extension CBMUUID {
    static let flipperZeroService = CBMUUID(string: "666C6970-7065-7220-7A65-726F20736964")

    static let manufacturerNameCharacteristic = CBMUUID(string: "2A29")
    static let modelNumberCharacteristic = CBMUUID(string: "2A24")
    static let firmwareRevisionCharacteristic = CBMUUID(string: "2A26")
    static let softwareRevisionCharacteristic = CBMUUID(string: "2A28")
}

extension CBMCharacteristicMock {

    static let manufacturerNameCharacteristic = CBMCharacteristicMock(
        type: .manufacturerNameCharacteristic,
        properties: [.read]
    )

    static let modelNumberCharacteristic = CBMCharacteristicMock(
        type: .modelNumberCharacteristic,
        properties: [.read]
    )

    static let firmwareRevisionCharacteristic = CBMCharacteristicMock(
        type: .firmwareRevisionCharacteristic,
        properties: [.read]
    )

    static let softwareRevisionCharacteristic = CBMCharacteristicMock(
        type: .softwareRevisionCharacteristic,
        properties: [.read]
    )
}

extension CBMServiceMock {
    static let deviceInformationService = CBMServiceMock(
        type: .deviceInformation,
        primary: true,
        characteristics: [
            .manufacturerNameCharacteristic,
            .modelNumberCharacteristic,
            .firmwareRevisionCharacteristic,
            .softwareRevisionCharacteristic
        ]
    )
}

private class FlipperCBMPeripheralSpecDelegate: CBMPeripheralSpecDelegate {
    func peripheral(
        _ peripheral: CBMPeripheralSpec,
        didReceiveReadRequestFor characteristic: CBMCharacteristicMock
    ) -> Result<Data, Error> {
        let result: Result<String, Error>
        switch characteristic.uuid {
        case .manufacturerNameCharacteristic:
            result = .success("manufacturer")
        case .modelNumberCharacteristic:
            result = .success("model")
        case .firmwareRevisionCharacteristic:
            result = .success("firmware")
        case .softwareRevisionCharacteristic:
            result = .success("software")
        default:
            // FIXME: return an error
            result = .success("<error>")
        }
        switch result {
        case let .success(string):
            return .success(.init([UInt8](string.appending("\n").utf8)))
        case let .failure(error):
            return .failure(error)
        }
    }

    func peripheral(
        _ peripheral: CBMPeripheralSpec,
        didReceiveWriteRequestFor characteristic: CBMCharacteristicMock,
        data: Data
    ) -> Result<Void, Error> {
        // TODO: save the data
        return .success(())
    }
}

let flipper = CBMPeripheralSpec
    .simulatePeripheral(identifier: UUID(), proximity: .near)
    .advertising(
        advertisementData: [
            CBMAdvertisementDataLocalNameKey: "Flipper Zero",
            CBMAdvertisementDataServiceUUIDsKey: [CBMUUID.flipperZeroService],
            CBMAdvertisementDataIsConnectable: true as NSNumber
        ],
        withInterval: 0.250,
        alsoWhenConnected: false)
    .connectable(
        name: "Flipper Zero",
        services: [.deviceInformationService],
        delegate: FlipperCBMPeripheralSpecDelegate(),
        connectionInterval: 0.150,
        mtu: 23)
    .build()
