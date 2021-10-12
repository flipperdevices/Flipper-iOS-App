import Core
import Combine
import Injector
import Foundation

class PingViewModel: ObservableObject {
    @Inject var connector: BluetoothConnector

    @Published var requestTimestamp: String = ""
    @Published var responseTimestamp: String = ""
    private var disposeBag: DisposeBag = .init()

    var device: BluetoothPeripheral?

    init() {
        connector.connectedPeripherals
            .sink { [weak self] in
                self?.device = $0.first
            }
            .store(in: &disposeBag)
    }

    func sendPing() {
        guard let device = device else {
            print("no device connected")
            return
        }
        requestTimestamp = .init(Date().timeIntervalSince1970)
        device.send(.ping) { _ in
            self.responseTimestamp = .init(Date().timeIntervalSince1970)
        }
    }
}
