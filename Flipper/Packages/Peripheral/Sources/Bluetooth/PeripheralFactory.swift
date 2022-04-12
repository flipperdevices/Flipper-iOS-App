import CoreBluetooth

protocol PeripheralFactory {
    func create(
        peripheral: CBPeripheral,
        service: CBUUID?
    ) -> BluetoothPeripheral
}

extension PeripheralFactory {
    func create(peripheral: CBPeripheral) -> BluetoothPeripheral {
        create(peripheral: peripheral, service: nil)
    }
}
