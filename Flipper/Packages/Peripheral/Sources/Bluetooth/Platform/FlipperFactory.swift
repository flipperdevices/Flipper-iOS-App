import CoreBluetooth

class FlipperFactory: PeripheralFactory {
    private var services: [UUID: CBUUID] = [:]

    func create(
        peripheral: CBPeripheral,
        service: CBUUID?
    ) -> BluetoothPeripheral {
        if let service = service {
            services[peripheral.identifier] = service
        }
        return FlipperPeripheral(
            peripheral: peripheral,
            colorService: services[peripheral.identifier])
    }
}
