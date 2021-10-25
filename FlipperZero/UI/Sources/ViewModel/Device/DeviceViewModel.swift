import Core
import Combine
import Injector
import struct Foundation.UUID

public class DeviceViewModel: ObservableObject {
    @Inject var flipper: PairedDeviceProtocol
    private var disposeBag: DisposeBag = .init()

    private let archive: Archive = .shared

    @Published var device: Peripheral? {
        didSet { status = .init(device?.state) }
    }
    @Published var status: HeaderDeviceStatus = .noDevice

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
        flipper.peripheral
            .sink { [weak self] in
                self?.device = $0
            }
            .store(in: &disposeBag)
    }

    func sync() {
        status = .synchronizing
        archive.syncWithDevice { [weak self] in
            self?.status = .init(self?.device?.state)
        }
    }
}
