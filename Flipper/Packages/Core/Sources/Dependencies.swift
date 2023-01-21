import Inject
import Combine

@MainActor
public class Depencencies: ObservableObject {
    public let appState: AppState = .init()

    // MARK: Services

    public lazy var applicationService: ApplicationService = {
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

    public lazy var flipperService: FlipperService = {
        .init(appState: appState)
    }()

    public lazy var archiveService: ArchiveService = {
        .init(appState: appState, syncService: syncService)
    }()

    public lazy var syncService: SyncService = {
        .init(appState: appState)
    }()

    public lazy var updateService: UpdateService = {
        .init(appState: appState, flipperService: flipperService)
    }()

    public lazy var checkUpdateService: CheckUpdateService = {
        .init(appState: appState, updateService: updateService)
    }()

    public lazy var emulateService: EmulateService = {
        .init(appState: appState)
    }()

    public lazy var sharingService: SharingService = {
        .init()
    }()

    public lazy var widgetService: WidgetService = {
        .init(appState: appState, emulateService: emulateService)
    }()

    public init() {}
}
