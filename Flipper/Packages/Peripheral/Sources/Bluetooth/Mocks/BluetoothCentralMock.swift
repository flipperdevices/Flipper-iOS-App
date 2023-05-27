import Combine
import Foundation
import Collections

class BluetoothCentralMock: BluetoothCentral {
    private let initialStatus: BluetoothStatus
    private var isScanning = false

    init(status: BluetoothStatus) {
        self.initialStatus = status
    }

    // MARK: BluetoothCentral

    private let statusSubject: CurrentValueSubject<BluetoothStatus, Never> =
        .init(BluetoothStatus.poweredOn)
    private let peripheralsSubject: CurrentValueSubject<[BluetoothPeripheral], Never> =
        .init([BluetoothPeripheral]())

    var status: AnyPublisher<BluetoothStatus, Never> {
        self.statusSubject.eraseToAnyPublisher()
    }

    var discovered: AnyPublisher<[BluetoothPeripheral], Never> {
        self.peripheralsSubject.eraseToAnyPublisher()
    }

    private var peripheralsMap: OrderedDictionary<UUID, BluetoothPeripheralMock> = [:] {
        didSet { publishPeripherals() }
    }

    private func publishPeripherals() {
        peripheralsSubject.value = [BluetoothPeripheralMock](peripheralsMap.values)
    }

    func startScanForPeripherals() {
        guard statusSubject.value == .poweredOn else {
            print("Bluetooth is not ready")
            return
        }
        guard !isScanning else { return }
        isScanning = true
        Task {
            try await Task.sleep(nanoseconds: 500_000_000)
            let peripheral = BluetoothPeripheralMock()
            peripheralsMap[peripheral.id] = .init(peripheral)
        }
    }

    func stopScanForPeripherals() {
        if isScanning {
            peripheralsMap.removeAll()
            isScanning = false
        }
    }

    // MARK: BluetoothConnector

    private let connectedPeripheralsSubject: CurrentValueSubject<[BluetoothPeripheral], Never>
        = .init([])

    var connected: AnyPublisher<[BluetoothPeripheral], Never> {
        self.connectedPeripheralsSubject.eraseToAnyPublisher()
    }

    private var connectedPeripheralsMap = [UUID: BluetoothPeripheralMock]() {
        didSet { publishConnectedPeripherals() }
    }

    private func publishConnectedPeripherals() {
        connectedPeripheralsSubject.value = [BluetoothPeripheralMock](connectedPeripheralsMap.values)
    }

    func connect(to identifier: UUID) {
        guard let peripheral = peripheralsMap[identifier] else {
            return
        }
        Task {
            peripheral.state = .connecting
            connectedPeripheralsMap[identifier] = peripheral
            try await Task.sleep(nanoseconds: 500_000_000)
            peripheral.state = .connected
            connectedPeripheralsMap[identifier] = peripheral
            peripheral.onConnect()
        }
    }

    func disconnect(from identifier: UUID) {
        guard let peripheral = connectedPeripheralsMap[identifier] else {
            return
        }
        peripheral.state = .disconnecting
        connectedPeripheralsMap[identifier] = peripheral
        peripheral.state = .disconnected
        connectedPeripheralsMap[identifier] = nil
        peripheral.onDisconnect()
    }
}
