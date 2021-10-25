import Core
import Combine
import Injector
import struct Foundation.UUID

public class DeviceViewModel: ObservableObject {
    @Inject var connector: BluetoothConnector
    @Inject var storage: DeviceStorage
    var flipper: BluetoothPeripheral? {
        didSet { subscribeToUpdates() }
    }
    private var disposeBag: DisposeBag = .init()

    var isReconnecting = false
    @Published var device: Peripheral? {
        didSet {
            storage.pairedDevice = device
        }
    }

    var firmwareVersion: String {
        guard let device = device else { return .noDevice }
        guard let info = device.information else { return .unknown }

        let version = info
            .softwareRevision
            .value
            .split(separator: " ")
            .prefix(2)
            .reversed()
            .joined(separator: " ")

        return .init(version)
    }

    var firmwareBuild: String {
        guard let device = device else { return .noDevice }
        guard let info = device.information else { return .unknown }

        let build = info
            .softwareRevision
            .value
            .split(separator: " ")
            .suffix(1)
            .joined(separator: " ")

        return .init(build)
    }

    public init() {
        if let pairedDevice = storage.pairedDevice {
            isReconnecting = true
            self.device = pairedDevice
            reconnectOnBluetoothReady(to: pairedDevice.id)
        }
        saveLastConnectedDeviceOnConnect()
    }

    func reconnectOnBluetoothReady(to uuid: UUID) {
        connector.status
            .sink { [weak self] status in
                if status == .ready {
                    self?.connector.connect(to: uuid)
                }
            }
            .store(in: &disposeBag)
    }

    func saveLastConnectedDeviceOnConnect() {
        connector
            .connectedPeripherals
            .sink { [weak self] peripherals in
                guard let self = self else { return }
                guard let peripheral = peripherals.first else {
                    if self.isReconnecting { self.isReconnecting = false }
                    return
                }
                switch peripheral.state {
                // TODO: handle .connecting
                case .connecting, .connected:
                    self.flipper = peripheral
                    self.device = .init(peripheral)
                default:
                    self.flipper = nil
                    self.device = nil
                }
            }
            .store(in: &disposeBag)
    }

    func subscribeToUpdates() {
        flipper?.info
            .sink { [weak self] in
                if let flipper = self?.flipper {
                    self?.device = .init(flipper)
                }
            }
            .store(in: &disposeBag)
    }

    func sync() {
        // nothing here yet
    }
}
