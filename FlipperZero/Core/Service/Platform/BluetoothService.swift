//
//  BluetoothService.swift
//  FlipperZero
//
//  Created by Eugene Berdnikov on 8/22/20.
//

import CoreBluetooth

class BluetoothService: NSObject, BluetoothConnector {
    private let manager: CBCentralManager
    private let peripheralsSubject = SafeSubject([Peripheral]())
    private let statusSubject = SafeSubject(BluetoothStatus.notReady(.preparing))

    var peripherals: SafePublisher<[Peripheral]> {
        self.peripheralsSubject.eraseToAnyPublisher()
    }

    private var peripheralsMap = [UUID: CBPeripheral]() {
        didSet {
            self.peripheralsSubject.value =
                self.peripheralsMap.values.compactMap(Peripheral.init).sorted { $0.name < $1.name }
        }
    }

    var status: SafePublisher<BluetoothStatus> {
        self.statusSubject.eraseToAnyPublisher()
    }

    override init() {
        self.manager = CBCentralManager()
        super.init()
        self.manager.delegate = self
    }

    func startScanForPeripherals() {
        if self.statusSubject.value == .ready {
            // TODO: Provide CBUUID relevant to Flipper devices
            self.manager.scanForPeripherals(withServices: nil)
        }
    }

    func stopScanForPeripherals() {
        if self.manager.isScanning {
            self.peripheralsMap.removeAll()
            self.manager.stopScan()
        }
    }
}

extension BluetoothService: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ manager: CBCentralManager) {
        let status = BluetoothStatus(manager.state)
        self.statusSubject.value = status
        if status != .ready {
            self.peripheralsMap.removeAll()
        }
    }

    func centralManager(
        _: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi: NSNumber
    ) {
        if self.peripheralsMap[peripheral.identifier] == nil,
            let isConnectable = advertisementData[CBAdvertisementDataIsConnectable] as? Bool,
            isConnectable {

            self.peripheralsMap[peripheral.identifier] = peripheral
        }
    }
}

fileprivate extension BluetoothStatus {
    init(_ source: CBManagerState) {
        switch source {
        case .resetting, .unknown:
            self = .notReady(.preparing)
        case .unsupported:
            self = .notReady(.unsupported)
        case .unauthorized:
            self = .notReady(.unauthorized)
        case .poweredOff:
            self = .notReady(.poweredOff)
        case .poweredOn:
            self = .ready
        @unknown default:
            self = .notReady(.unsupported)
        }
    }
}

fileprivate extension Peripheral {
    init?(_ source: CBPeripheral) {
        guard let name = source.name else {
            return nil
        }

        self.id = source.identifier
        self.name = name
    }
}
