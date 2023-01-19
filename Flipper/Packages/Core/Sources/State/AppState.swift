import Inject
import Analytics
import Peripheral
import Foundation
import Combine
import Logging

@MainActor
public class AppState: ObservableObject {
    @Published public var status: DeviceStatus = .noDevice

    @Published public var update: UpdateModel = .init()
    @Published public var updateAvailable: VersionUpdateModel = .init()

    @Published public var emulate: EmulateModel = .init()
    @Published public var readerAttack: ReaderAttackModel = .init()

    @Published public var widget: WidgetModel = .init()

    @Published public var hasMFLog = false
    public let imported = SafeSubject<ArchiveItem>()

    public init() {
        logger.info("app version: \(Bundle.fullVersion)")
        logger.info("log level: \(UserDefaultsStorage.shared.logLevel)")
    }
}
