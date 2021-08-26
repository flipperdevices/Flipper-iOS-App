import Combine
import struct Foundation.UUID

class ConnectionsViewModel: ObservableObject {
    enum State: Equatable {
        case notReady(String)
        case scanning([Peripheral])

        init(_ notReadyReason: BluetoothStatus.NotReadyReason) {
            self = .notReady(notReadyReason.description)
        }
    }

    @Inject private var connector: BluetoothConnector
    private var disposeBag = DisposeBag()

    @Published private(set) var state: State = .init(.preparing) {
        didSet {
            let newValue = self.state
            if case .notReady = oldValue, case .scanning = newValue {
                self.connector.startScanForPeripherals()
            }
        }
    }

    init() {
        connector.status
            .combineLatest(connector.peripherals)
            .map { status, peripherals -> State in
                switch status {
                case .ready:
                    return .scanning(peripherals)
                case .notReady(let reason):
                    return .notReady(reason.description)
                }
            }.removeDuplicates(by: ==).eraseToAnyPublisher()
            .sink { [weak self] in
                self?.state = $0
            }.store(in: &self.disposeBag)
    }

    func connect(to uuid: UUID) {
        connector.connect(to: uuid)
    }

    deinit {
        self.connector.stopScanForPeripherals()
    }
}

fileprivate extension BluetoothStatus.NotReadyReason {
    // TODO: support localizations here
    var description: String {
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
