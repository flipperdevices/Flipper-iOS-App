import CoreBluetooth

extension CBCentralManager {
    func retrievePeripheral(_ id: UUID) -> CBPeripheral? {
        retrievePeripherals(withIdentifiers: [id]).first
    }
}
