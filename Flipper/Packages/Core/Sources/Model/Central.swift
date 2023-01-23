import Inject
import Peripheral

import Combine
import Foundation

@MainActor
public class Central: ObservableObject {
    private var central: BluetoothCentral
    private var disposeBag = DisposeBag()

    @Published public private(set) var state: BluetoothStatus = .unknown

    let scanTimeoutInSeconds = 30
    @Published public var isScanTimeout = false

    let connectTimeoutInSeconds = 30
    @Published public var isConnectTimeout = false

    var uuid: UUID?

    @Published public var flippers: [Flipper] = []

    private var bluetoothPeripherals: [BluetoothPeripheral] = [] {
        didSet { updateFlippers() }
    }

    private var connectedPeripherals: [BluetoothPeripheral] = [] {
        didSet { updateFlippers() }
    }

    public var isConnecting: Bool {
        !connectedPeripherals.isEmpty
    }

    public init(central: BluetoothCentral = Peripheral.Dependencies.central) {
        self.central = central
        subscribeToPublishers()
    }

    func subscribeToPublishers() {
        central.status
            .receive(on: DispatchQueue.main)
            .assign(to: \.state, on: self)
            .store(in: &disposeBag)

        central.discovered
            .receive(on: DispatchQueue.main)
            .filter { !$0.isEmpty }
            .assign(to: \.bluetoothPeripherals, on: self)
            .store(in: &disposeBag)

        central.connected
            .receive(on: DispatchQueue.main)
            .assign(to: \.connectedPeripherals, on: self)
            .store(in: &disposeBag)
    }

    private func updateFlippers() {
        var flippers = bluetoothPeripherals.map(Flipper.init)
        for next in connectedPeripherals {
            if let index = flippers.firstIndex(where: { $0.id == next.id }) {
                flippers[index].state = next.state
            }
        }
        self.flippers = flippers
    }

    public func kickBluetoothCentral() {
        central.startScanForPeripherals()
        central.stopScanForPeripherals()
    }

    public func startScan() {
        central.startScanForPeripherals()
        startScanTimer()
    }

    public func stopScan() {
        central.stopScanForPeripherals()
        flippers.removeAll()
        stopScanTimer()
        stopConnectTimer()
    }

    public func connect(to uuid: UUID) {
        self.uuid = uuid
        logger.info("pairing")
        central.connect(to: uuid)
        startConnectTimer()
    }

    // MARK: Scan timeout

    private var scanTimeoutTask: Task<Void, Swift.Error>?

    private func startScanTimer() {
        stopScanTimer()
        scanTimeoutTask = Task {
            try await Task.sleep(seconds: scanTimeoutInSeconds)
            if flippers.isEmpty {
                stopScan()
                isScanTimeout = true
            }
        }
    }

    private func stopScanTimer() {
        scanTimeoutTask?.cancel()
        scanTimeoutTask = nil
        isScanTimeout = false
    }

    // MARK: Connect timeout

    private var connectTimeoutTask: Task<Void, Swift.Error>?

    private func startConnectTimer() {
        stopConnectTimer()
        connectTimeoutTask = Task {
            try await Task.sleep(seconds: connectTimeoutInSeconds)
            if self.isConnecting, let uuid = self.uuid {
                self.central.disconnect(from: uuid)
                self.isConnectTimeout = true
            }
        }
    }

    private func stopConnectTimer() {
        connectTimeoutTask?.cancel()
        connectTimeoutTask = nil
        isConnectTimeout = false
    }
}
