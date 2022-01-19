import Core
import Combine
import Inject
import Foundation

@MainActor
class ConnectionsViewModel: ObservableObject {
    @Inject private var central: BluetoothCentral
    @Inject private var connector: BluetoothConnector
    private var disposeBag = DisposeBag()

    @Published private(set) var state: BluetoothStatus = .notReady(.preparing) {
        didSet {
            switch state {
            case .ready: startScan()
            case .notReady: stopScan()
            }
        }
    }

    @Published private(set) var peripherals: [Peripheral] = []

    var isConnecting: Bool {
        peripherals.contains { $0.state != .disconnected }
    }

    init() {
        central.status
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.state = $0
            }
            .store(in: &disposeBag)

        central.peripherals
            .receive(on: DispatchQueue.main)
            .filter { !$0.isEmpty }
            .sink { [weak self] in
                self?.peripherals = $0.map(Peripheral.init)
            }
            .store(in: &disposeBag)

        connector.connectedPeripherals
            .receive(on: DispatchQueue.main)
            .sink { [weak self] connected in
                connected.forEach { self?.update($0) }
            }
            .store(in: &disposeBag)
    }

    func update(_ peripheral: BluetoothPeripheral) {
        if let index = peripherals.firstIndex(
            where: { $0.id == peripheral.id }
        ) {
            self.peripherals[index] = .init(peripheral)
        }
    }

    func startScan() {
        central.startScanForPeripherals()
    }

    func stopScan() {
        central.stopScanForPeripherals()
        peripherals.removeAll()
    }

    func connect(to uuid: UUID) {
        connector.connect(to: uuid)
    }

    func openApplicationSettings() {
        Application.openSettings()
    }
}

extension BluetoothStatus.NotReadyReason: CustomStringConvertible {
    // TODO: support localizations here
    public var description: String {
        switch self {
        case .poweredOff:
            return "Bluetooth is powered off"
        case .preparing:
            return "Bluetooth is not ready"
        case .unauthorized:
            return "The application is not authorized to use Bluetooth"
        case .unsupported:
            return "Bluetooth is not supported on this device"
        }
    }
}
