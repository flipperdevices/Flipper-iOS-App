import Core
import Combine
import Inject
import Foundation

@MainActor
class ConnectionViewModel: ObservableObject {
    let appState: AppState = .shared

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

    var scanTimer: Timer?
    let scanTimoutInSecons = 30.0
    @Published var isScanTimeout = false

    var connectTimer: Timer?
    let connectTimoutInSecons = 30.0
    @Published var isConnectTimeout = false

    var uuid: UUID?
    @Published var isCanceledOrInvalidPin = false {
        didSet { pairedDevice.forget() }
    }

    @Published var isPairingIssue = false {
        didSet { pairedDevice.forget() }
    }

    @Published var peripherals: [Peripheral] = []

    private var bluetoothPeripherals: [BluetoothPeripheral] = [] {
        didSet { updatePeripherals() }
    }

    var isConnecting: Bool {
        bluetoothPeripherals.contains { $0.state != .disconnected }
    }

    init() {
        central.status
            .receive(on: DispatchQueue.main)
            .assign(to: \.state, on: self)
            .store(in: &disposeBag)

        central.peripherals
            .receive(on: DispatchQueue.main)
            .filter { !$0.isEmpty }
            .assign(to: \.bluetoothPeripherals, on: self)
            .store(in: &disposeBag)

        connector.connectedPeripherals
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updatePeripherals()
            }
            .store(in: &disposeBag)

        appState.$status
            .receive(on: DispatchQueue.main)
            .map { $0 == .pairingIssue }
            .filter { $0 == true }
            .assign(to: \.isPairingIssue, on: self)
            .store(in: &disposeBag)

        appState.$status
            .receive(on: DispatchQueue.main)
            .map { $0 == .failed }
            .filter { $0 == true }
            .assign(to: \.isCanceledOrInvalidPin, on: self)
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

    func updatePeripherals() {
        peripherals = bluetoothPeripherals.map(Peripheral.init)
    }

    func startScan() {
        central.startScanForPeripherals()
        startScanTimer()
    }

    func stopScan() {
        central.stopScanForPeripherals()
        peripherals.removeAll()
        stopScanTimer()
        stopConnectTimer()
    }

    func connect(to uuid: UUID) {
        self.uuid = uuid
        connector.connect(to: uuid)
        startConnectTimer()
    }

    // MARK: Scan timeout

    func startScanTimer() {
        isScanTimeout = false
        scanTimer = .scheduledTimer(
            withTimeInterval: scanTimoutInSecons,
            repeats: false
        ) { [weak self] _ in
            guard let self = self else { return }
            if self.peripherals.isEmpty {
                self.stopScan()
                self.isScanTimeout = true
            }
        }
    }

    func stopScanTimer() {
        scanTimer?.invalidate()
        scanTimer = nil
    }

    // MARK: Connect timout

    func startConnectTimer() {
        isConnectTimeout = false
        connectTimer = .scheduledTimer(
            withTimeInterval: connectTimoutInSecons,
            repeats: false
        ) { [weak self] _ in
            guard let self = self else { return }
            if self.isConnecting, let uuid = self.uuid {
                self.connector.disconnect(from: uuid)
                self.isConnectTimeout = true
            }
        }
    }

    func stopConnectTimer() {
        connectTimer?.invalidate()
        connectTimer = nil
    }
}
