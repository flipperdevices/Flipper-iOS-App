import Macro
import Analytics
import Peripheral
import Catalog

import Logging
import Combine
import Foundation

// Temporary service locator while refactoring in progress

public class Dependencies: ObservableObject {
    private static let queue = DispatchQueue(label: "com.flipper.dependencies")

    private static var sharedInstance: Dependencies?

    public static var shared: Dependencies {
        return queue.sync {
            sharedInstance ?? {
                let instance = Dependencies()
                sharedInstance = instance
                return instance
            }()
        }
    }

    private init() {
        LoggingSystem.bootstrap { _ in
            FileLogHandler(storage: self.loggerStorage)
        }
        AnalyticsSystem.bootstrap(
            [CountlyAnalytics(), ClickhouseAnalytics()]
        )

        logger.info("app version: \(Bundle.fullVersion)")
        logger.info("log level: \(UserDefaultsStorage.shared.logLevel)")
    }

    // MARK: Domain Model

    // logger

    public lazy var loggerStorage: LoggerStorage = {
        PlainLoggerStorage()
    }()

    // device

    public lazy var pairedDevice: PairedDevice = {
        PairedFlipper(
            central: Peripheral.Dependencies.central,
            storage: PlainDeviceStorage()
        )
    }()

    // api

    private lazy var api: API = {
        .init(pairedDevice: pairedDevice)
    }()

    // archive

    public lazy var mobileArchiveStorage: ArchiveStorage = {
        MobileArchiveStorage()
    }()

    public lazy var archive: Archive = {
        let mobileArchive = MobileArchive(
            storage: mobileArchiveStorage
        )
        let mobileFavorites = MobileFavorites()
        let syncedManifest = SyncedItemsStorage()

        return Archive(
            archiveSync: ArchiveSync(
                flipperArchive: FlipperArchive(
                    storage: api.storage
                ),
                mobileArchive: mobileArchive,
                syncedManifest: syncedManifest),
            favoritesSync: FavoritesSync(
                mobileFavorites: mobileFavorites,
                flipperFavorites: FlipperFavorites(
                    storage: api.storage
                ),
                syncedFavorites: SyncedFavorites()),
            mobileFavorites: mobileFavorites,
            mobileArchive: mobileArchive,
            mobileNotes: NotesArchiveStorage(),
            deletedArchive: DeletedArchive(
                storage: DeletedArchiveStorage()
            ),
            syncedManifest: syncedManifest)
    }()

    // MARK: Application Model

    @MainActor
    public lazy var router: Router = {
        .init()
    }()

    @MainActor
    public lazy var central: Central = {
        .init(central: Peripheral.Dependencies.central)
    }()

    @MainActor
    public lazy var device: Device = {
        .init(
            central: central,
            pairedDevice: pairedDevice,
            system: api.system,
            storage: api.storage,
            desktop: api.desktop,
            gui: api.gui)
    }()

    @MainActor
    public lazy var networkMonitor: NetworkMonitor = {
        .init()
    }()

    @MainActor
    public lazy var archiveModel: ArchiveModel = {
        .init(archive: archive, synchronization: synchronization)
    }()

    @MainActor
    public lazy var synchronization: Synchronization = {
        .init(
            archive: archive,
            device: device,
            system: api.system,
            storage: api.storage)
    }()

    @MainActor
    public lazy var updateModel: UpdateModel = {
        .init(
            device: device,
            pairedDevice: pairedDevice,
            manifestSource: RemoteTargetManifestSource(
                manifestSource: RemoteFirmwareManifestSource()),
            firmwareProvider: .init(),
            firmwareUploder: .init(storage: api.storage)
        )
    }()

    @MainActor
    public lazy var emulate: Emulate = {
        .init(application: api.application)
    }()

    @MainActor
    public lazy var sharing: SharingModel = {
        .init()
    }()

    @MainActor
    public var detectReader: DetectReader {
        .init(
            pairedDevice: pairedDevice,
            storage: api.storage,
            mfKnownKeys: .init(storage: api.storage))
    }

    @MainActor
    public lazy var applications: Applications = {
        var devURL = #URL("https://catalog.flipp.dev/api/v0")
        var prodURL = #URL("https://catalog.flipperzero.one/api/v0")

        return .init(
            catalog: WebCatalog(
                baseURL: UserDefaultsStorage.shared.isDevCatalog
                    ? devURL
                    : prodURL),
            flipperApps: .init(
                storage: api.storage,
                cache: CacheStorage()),
            pairedDevice: pairedDevice,
            system: api.system,
            application: api.application
        )
    }()

    @MainActor
    public lazy var widget: TodayWidget = {
        .init(
            widgetStorage: FilteredWidgetStorage(
                widgetStorage: JSONTodayWidgetStorage(),
                mobileStorage: mobileArchiveStorage),
            emulate: emulate,
            archive: archive,
            central: central,
            device: pairedDevice)
    }()

    // utils

    @MainActor
    public var pingTest: PingTest {
        .init(system: api.system)
    }
    @MainActor
    public var speedTest: SpeedTest {
        .init(system: api.system)
    }
    @MainActor
    public var stressTest: StressTest {
        .init(
            pairedDevice: pairedDevice,
            storage: api.storage)
    }
    @MainActor
    public var fileManager: RemoteFileManager {
        .init(storage: api.storage)
    }
}

extension API {
    init(pairedDevice: PairedDevice) {
        self.init(
            system: FlipperSystemAPI(pairedDevice: pairedDevice),
            storage: FlipperStorageAPI(pairedDevice: pairedDevice),
            desktop: FlipperDesktopAPI(pairedDevice: pairedDevice),
            gui: FlipperGUIAPI(pairedDevice: pairedDevice),
            application: FlipperApplicationAPI(pairedDevice: pairedDevice))
    }
}
