import class CoreBluetooth.CBUUID

extension CBUUID {
    static var flipperZerof6: CBUUID { .init(string: "3080") }
    static var flipperZeroBlack: CBUUID { .init(string: "3081") }
    static var flipperZeroWhite: CBUUID { .init(string: "3082") }

    // service
    static var deviceInformation: CBUUID { .init(string: "180A") }
    // characteristics
    static var manufacturerName: CBUUID { .init(string: "2A29") }
    static var serialNumber: CBUUID { .init(string: "2A25") }
    static var firmwareRevision: CBUUID { .init(string: "2A26") }
    static var softwareRevision: CBUUID { .init(string: "2A28") }

    // service
    static var battery: CBUUID { .init(string: "180F") }
    // characteristics
    static var batteryLevel: CBUUID { .init(string: "2A19") }

    // service
    static var serial: CBUUID { .init(string: "8FE5B3D5-2E7F-4A98-2A48-7ACC60FE0000") }
    // characteristics
    static var serialRead: CBUUID { .init(string: "19ED82AE-ED21-4C9D-4145-228E61FE0000") }
    static var serialWrite: CBUUID { .init(string: "19ED82AE-ED21-4C9D-4145-228E62FE0000") }
    static var flowControl: CBUUID { .init(string: "19ED82AE-ED21-4C9D-4145-228E63FE0000") }
}
