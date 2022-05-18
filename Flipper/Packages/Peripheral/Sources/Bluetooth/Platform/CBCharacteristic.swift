import CoreBluetooth

extension Array where Element == CBCharacteristic {

    // MARK: Device Information

    var manufacturerName: CBCharacteristic? {
        first { $0.uuid == .manufacturerName }
    }

    var serialNumber: CBCharacteristic? {
        first { $0.uuid == .serialNumber }
    }

    var firmwareRevision: CBCharacteristic? {
        first { $0.uuid == .firmwareRevision }
    }

    var softwareRevision: CBCharacteristic? {
        first { $0.uuid == .softwareRevision }
    }

    var protobufRevision: CBCharacteristic? {
        first { $0.uuid == .protobufRevision }
    }

    // MARK: Battery

    var batteryLevel: CBCharacteristic? {
        first { $0.uuid == .batteryLevel }
    }

    var batteryPowerState: CBCharacteristic? {
        first { $0.uuid == .batteryPowerState }
    }

    // MARK: Serial Service

    var serialRead: CBCharacteristic? {
        first { $0.uuid == .serialRead }
    }

    var serialWrite: CBCharacteristic? {
        first { $0.uuid == .serialWrite }
    }

    var flowControl: CBCharacteristic? {
        first { $0.uuid == .flowControl }
    }
}
