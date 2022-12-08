import Inject
import Combine

@MainActor
class Depencencies: ObservableObject {
    @Inject var appState: AppState

    // MARK: Services

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
        .init()
    }()

    public lazy var archiveService: ArchiveService = {
        .init()
    }()

    public lazy var updateService: UpdateService = {
        .init(appState: appState, flipperService: flipperService)
    }()

    public lazy var widgetService: WidgetService = {
        .init()
    }()

    public init() {}
}
