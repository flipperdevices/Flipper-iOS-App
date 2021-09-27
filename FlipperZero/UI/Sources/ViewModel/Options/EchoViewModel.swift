import Core
import Combine
import Injector
import struct Foundation.UUID

class EchoViewModel: ObservableObject {
    @Inject var connector: BluetoothConnector

    @Published var isEditing = false
    @Published var received: [Message] = []
    private var disposeBag: DisposeBag = .init()

    struct Message: Identifiable {
        let id: UUID = .init()
        let text: String
    }

    var flipper: BluetoothPeripheral? {
        didSet { onDeviceChanged() }
    }

    init() {
        connector.connectedPeripherals
            .sink { [weak self] in
                self?.flipper = $0.first
            }
            .store(in: &disposeBag)
    }

    func onDeviceChanged() {
        flipper?.received
            .sink { [weak self] bytes in
                guard let self = self else { return }
                guard !bytes.isEmpty else { return }
                let text = String(decoding: bytes, as: UTF8.self)
                guard !text.isEmpty else { return }
                self.received.append(.init(text: text))
            }
            .store(in: &disposeBag)
    }

    func send(_ text: String) {
        guard let flipper = flipper else {
            print("no device connected")
            return
        }
        guard let data = text.data(using: .ascii) else {
            print("invalid input")
            return
        }
        flipper.send(.init(data))
    }
}
