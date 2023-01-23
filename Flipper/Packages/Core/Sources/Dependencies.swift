import Inject
import Combine
import Peripheral

@MainActor
public class Dependencies: ObservableObject {

    // Service

    public lazy var central: BluetoothCentral = {
        Peripheral.Dependencies.central
    }()

    // Model

    public lazy var router: Router = {
        .init()
    }()

    public lazy var loggerService: LoggerService = {
        .init()
    }()

    public lazy var networkService: NetworkService = {
        .init()
    }()

    public lazy var centralService: CentralService = {
        .init(central: central)
    }()

    public lazy var device: Device = {
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
        .init(updateService: updateService)
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

    public init() {}
}
