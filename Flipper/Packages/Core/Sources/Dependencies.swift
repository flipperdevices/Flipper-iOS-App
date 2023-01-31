import Inject
import Combine
import Peripheral
import Foundation

@MainActor
public class Dependencies: ObservableObject {

    // Model

    public lazy var router: Router = {
        .init()
    }()

    public lazy var central: Central = {
        .init()
    }()

    public lazy var device: Device = {
        .init()
    }()

    public lazy var networkMonitor: NetworkMonitor = {
        .init()
    }()

    public lazy var archiveService: ArchiveService = {
        .init(syncService: syncService)
    }()

    public lazy var syncService: SyncService = {
        .init(device: device)
    }()

    public lazy var updateService: UpdateService = {
        .init(device: device)
    }()

    public lazy var checkUpdateService: CheckUpdateService = {
        .init()
    }()

    public lazy var emulateService: EmulateService = {
        .init()
    }()

    public lazy var sharingService: SharingService = {
        .init()
    }()

    public lazy var widgetService: WidgetService = {
        .init(device: device, emulateService: emulateService)
    }()

    public init() {
        logger.info("app version: \(Bundle.fullVersion)")
        logger.info("log level: \(UserDefaultsStorage.shared.logLevel)")
    }
}
