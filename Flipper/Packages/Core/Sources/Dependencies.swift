import Analytics
import Peripheral

import Logging
import Combine
import Foundation

// Temporary service locator while refactoring in progress

public class Dependencies: ObservableObject {
    public static var shared: Dependencies = {
        .init()
    }()

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

    // archive

    public lazy var archive: Archive = {
        let mobileArchive = MobileArchive(
            storage: PlainMobileArchiveStorage()
        )
        let mobileFavorites = MobileFavorites()
        let syncedItems = PlainSyncedItemsStorage()

        return Archive(
            archiveSync: ArchiveSync(
                flipperArchive: FlipperArchive(
                    pairedDevice: pairedDevice
                ),
                mobileArchive: mobileArchive,
                syncedItems: syncedItems),
            favoritesSync: FavoritesSync(
                mobileFavorites: mobileFavorites,
                flipperFavorites: FlipperFavorites(
                    pairedDevice: pairedDevice
                ),
                syncedFavorites: SyncedFavorites()),
            mobileFavorites: mobileFavorites,
            mobileArchive: mobileArchive,
            mobileNotes: PlainMobileNotesStorage(),
            deletedArchive: DeletedArchive(
                storage: PlainDeletedArchiveStorage()
            ),
            syncedItems: syncedItems)
    }()

    // MARK: Application Model

    @MainActor
    public lazy var router: Router = {
        .init()
    }()

    @MainActor
    public lazy var central: Central = {
        .init()
    }()

    @MainActor
    public lazy var device: Device = {
        .init(pairedDevice: pairedDevice)
    }()

    @MainActor
    public lazy var networkMonitor: NetworkMonitor = {
        .init()
    }()

    @MainActor
    public lazy var archiveService: ArchiveService = {
        .init(archive: archive, syncService: syncService)
    }()

    @MainActor
    public lazy var syncService: SyncService = {
        .init(pairedDevice: pairedDevice, archive: archive, device: device)
    }()

    @MainActor
    public lazy var updateService: UpdateService = {
        .init(pairedDevice: pairedDevice, device: device)
    }()

    @MainActor
    public lazy var checkUpdateService: CheckUpdateService = {
        .init(pairedDevice: pairedDevice)
    }()

    @MainActor
    public lazy var emulateService: EmulateService = {
        .init(pairedDevice: pairedDevice)
    }()

    @MainActor
    public lazy var sharingService: SharingService = {
        .init()
    }()
}
