protocol BluetoothConnector {
    var peripherals: SafePublisher<[Peripheral]> { get }
    var status: SafePublisher<BluetoothStatus> { get }

    func startScanForPeripherals()
    func stopScanForPeripherals()
}
