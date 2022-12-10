import Inject
import Combine

@MainActor
public class Depencencies: ObservableObject {
    // TODO: refactor when we get rid of Inject
    @Inject public var appState: AppState

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
        .init(appState: appState)
    }()

    public lazy var updateService: UpdateService = {
        .init(appState: appState, flipperService: flipperService)
    }()

    public lazy var emulateService: EmulateService = {
        .init()
    }()

    public lazy var sharingService: SharingService = {
        .init()
    }()

    public lazy var widgetService: WidgetService = {
        .init()
    }()

    public init() {}
}
