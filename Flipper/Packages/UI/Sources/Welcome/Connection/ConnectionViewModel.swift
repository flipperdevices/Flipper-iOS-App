import Core
import Combine
import Inject
import Foundation
import Peripheral

@MainActor
class ConnectionViewModel: ObservableObject {
    @Inject private var appState: AppState

    @Inject private var central: BluetoothCentral
    @Inject private var connector: BluetoothConnector
    @Inject private var pairedDevice: PairedDevice
    private var disposeBag = DisposeBag()

    @Published private(set) var state: BluetoothStatus = .notReady(.preparing) {
        didSet {
            switch state {
            case .ready: startScan()
            case .notReady: stopScan()
            }
        }
    }

    @Published var showHelpSheet = false

    let scanTimeoutInSeconds = 30
    @Published var isScanTimeout = false

    let connectTimeoutInSeconds = 30
    @Published var isConnectTimeout = false

    var uuid: UUID?
    @Published var isCanceledOrInvalidPin = false {
        didSet { pairedDevice.forget() }
    }

    @Published var isPairingIssue = false {
        didSet { pairedDevice.forget() }
    }

    @Published var flippers: [Flipper] = []

    private var bluetoothPeripherals: [BluetoothPeripheral] = [] {
        didSet { updateFlippers() }
    }

    private var connectedPeripherals: [BluetoothPeripheral] = [] {
        didSet { updateFlippers() }
    }

    var isConnecting: Bool {
        !connectedPeripherals.isEmpty
    }

    init() {
        central.status
            .receive(on: DispatchQueue.main)
            .assign(to: \.state, on: self)
            .store(in: &disposeBag)

        central.discovered
            .receive(on: DispatchQueue.main)
            .filter { !$0.isEmpty }
            .assign(to: \.bluetoothPeripherals, on: self)
            .store(in: &disposeBag)

        connector.connected
            .receive(on: DispatchQueue.main)
            .assign(to: \.connectedPeripherals, on: self)
            .store(in: &disposeBag)

        appState.$status
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                switch status {
                case .invalidPairing: self?.isPairingIssue = true
                case .pairingFailed: self?.isCanceledOrInvalidPin = true
                case .connected: self?.disposeBag.removeAll()
                default: break
                }
            }
            .store(in: &disposeBag)
    }

    func reconnect() {
        if let uuid = uuid {
            connect(to: uuid)
        }
    }

    func skipConnection() {
        pairedDevice.forget()
        appState.isFirstLaunch = false
    }

    func updateFlippers() {
        var flippers = bluetoothPeripherals.map(Flipper.init)
        for next in connectedPeripherals {
            if let index = flippers.firstIndex(where: { $0.id == next.id }) {
                flippers[index].state = next.state
            }
        }
        self.flippers = flippers
    }

    func startScan() {
        central.startScanForPeripherals()
        startScanTimer()
    }

    func stopScan() {
        central.stopScanForPeripherals()
        flippers.removeAll()
        stopScanTimer()
        stopConnectTimer()
    }

    func connect(to uuid: UUID) {
        self.uuid = uuid
        connector.connect(to: uuid)
        startConnectTimer()
    }

    // MARK: Scan timeout

    private var scanTimeoutTask: Task<Void, Swift.Error>?

    func startScanTimer() {
        stopScanTimer()
        scanTimeoutTask = Task {
            try await Task.sleep(seconds: scanTimeoutInSeconds)
            if flippers.isEmpty {
                stopScan()
                isScanTimeout = true
            }
        }
    }

    func stopScanTimer() {
        scanTimeoutTask?.cancel()
        scanTimeoutTask = nil
        isScanTimeout = false
    }

    // MARK: Connect timout

    private var connectTimeoutTask: Task<Void, Swift.Error>?

    func startConnectTimer() {
        stopConnectTimer()
        connectTimeoutTask = Task {
            try await Task.sleep(seconds: connectTimeoutInSeconds)
            if self.isConnecting, let uuid = self.uuid {
                self.connector.disconnect(from: uuid)
                self.isConnectTimeout = true
            }
        }
    }

    func stopConnectTimer() {
        connectTimeoutTask?.cancel()
        connectTimeoutTask = nil
        isConnectTimeout = false
    }
}
