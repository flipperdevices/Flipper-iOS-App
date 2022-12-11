import Inject
import Analytics
import Peripheral
import Foundation
import Combine
import Logging

@MainActor
public class AppState: ObservableObject {
    private let logger = Logger(label: "app-state")

    @Published public var update: Update = .init()

    @Published public var readerAttack: ReaderAttackModel = .init()

    @Published public var firstLaunch: FirstLaunch = .shared

    @Published public var flipper: Flipper?
    @Published public var status: DeviceStatus = .noDevice
    @Published public var syncProgress: Int = 0

    @Published public var importQueue: [URL] = []
    @Published public var customFirmwareURL: URL?

    @Published public var hasMFLog = false
    @Published public var showWidgetSettings = false

    public let imported = SafeSubject<ArchiveItem>()

    public init() {
        logger.info("app version: \(Bundle.fullVersion)")
        logger.info("log level: \(UserDefaultsStorage.shared.logLevel)")
    }
}
