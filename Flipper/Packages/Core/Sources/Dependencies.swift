import Inject
import Combine

@MainActor
public class Depencencies: ObservableObject {
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
        .init()
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
