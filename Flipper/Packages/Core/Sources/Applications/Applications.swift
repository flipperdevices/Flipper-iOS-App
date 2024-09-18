import Macro
import Catalog
import Peripheral

import Logging
import Combine
import Foundation

@MainActor
public class Applications: ObservableObject {
    public typealias Category = Core.Category
    public typealias Application = Core.Application

    private var categories: [Category] = []

    public enum InstalledStatus {
        case loading
        case loaded
        case error
    }

    @Published public var installed: [Application] = []
    @Published public var installedStatus: InstalledStatus = .error
    public var statuses: [Application.ID: ApplicationStatus] = [:]
    public var statusChanged = PassthroughSubject<Application.ID, Never>()
    // Minimize CPU usage in background to prevent iOS from killing the app
    @Published public var enableProgressUpdates = true

    public var outdated: [Application] {
        installed.filter { statuses[$0.id] == .outdated }
    }

    public var outdatedCount: Int {
        outdated.count
    }

    public enum SortOption: String, CaseIterable {
        case newUpdates = "New Updates"
        case newReleases = "New Releases"
        case oldUpdates = "Old Updates"
        case oldReleases = "Old Releases"

        public static var `default`: SortOption { .newUpdates }
    }

    public enum Error: Swift.Error {
        case canceled
        case notFound
        case noInternet
        case unknownSDK
        case invalidIcon
        case invalidBuild
    }

    private var system: SystemAPI
    private var application: ApplicationAPI
    @Published private var flipper: Flipper?
    private var cancellables = [AnyCancellable]()

    private let catalog: CatalogService
    private let pairedDevice: PairedDevice

    private let flipperApps: FlipperApps

    init(
        catalog: CatalogService,
        flipperApps: FlipperApps,
        pairedDevice: PairedDevice,
        system: SystemAPI,
        application: ApplicationAPI
    ) {
        self.catalog = catalog
        self.flipperApps = flipperApps
        self.pairedDevice = pairedDevice
        self.system = system
        self.application = application

        subscribeToPublishers()
    }

    func subscribeToPublishers() {
        pairedDevice.flipper
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newValue in
                guard let self else { return }
                let oldValue = self.flipper
                self.flipper = newValue
                self.onFlipperChanged(oldValue)
            }
            .store(in: &cancellables)
    }

    public struct DeviceInfo {
        let target: String
        let api: String
    }

    @Published public var deviceInfo: DeviceInfo?
    @Published public var isOutdatedDevice: Bool = false

    func onFlipperChanged(_ oldValue: Flipper?) {
        if oldValue?.state != .connected, flipper?.state == .connected {
            guard flipper?.hasAPIVersion == true else {
                isOutdatedDevice = true
                return
            }
            Task {
                try await getDeviceInfo()
                try await loadInstalled()
            }
        } else if oldValue?.state == .connected, flipper?.state != .connected {
            isOutdatedDevice = false
            deviceInfo = nil
            installed = []
            statuses = [:]
        }
    }

    private func getDeviceInfo() async throws {
        let target = try await getFlipperTarget()
        let api = try await getFlipperAPI()
        deviceInfo = .init(target: target, api: api)
    }

    private func demoDelay() async {
        try? await Task.sleep(seconds: 1)
    }

    private func setStatus(
        _ status: ApplicationStatus?,
        for id: Application.ID
    ) {
        Task { @MainActor in
            statuses[id] = status
            statusChanged.send(id)
        }
    }

    let installQueue = SerialTaskQueue()

    public func install(_ application: Application) async {
        installed.append(application)
        setStatus(.installing(0), for: application.id)
        sortInstalled()

        await installQueue.enqueue { [self] in
            sortInstalled()
            do {
                try await _install(application) { progress in
                    if enableProgressUpdates {
                        setStatus(.installing(progress), for: application.id)
                    }
                }
                setStatus(.installed, for: application.id)
            } catch {
                logger.error("install app: \(error)")
            }
        }
        sortInstalled()
    }

    public func update(_ application: Application) async {
        setStatus(.updating(0), for: application.id)
        sortInstalled()

        await installQueue.enqueue { [self] in
            sortInstalled()
            do {
                try await _install(application) { progress in
                    if enableProgressUpdates {
                        setStatus(.updating(progress), for: application.id)
                    }
                }
                setStatus(.installed, for: application.id)
            } catch {
                logger.error("update app: \(error)")
            }
        }
        sortInstalled()
    }

    public func update(_ applications: [Application]) async {
        for application in applications {
            setStatus(.updating(0), for: application.id)
        }
        for application in applications {
            await update(application)
        }
    }

    public func delete(_ id: Application.ID) async {
        do {
            try await flipperApps.delete(id)
            installed.removeAll { $0.id == id }
            setStatus(nil, for: id)
        } catch {
            logger.error("delete app: \(error)")
        }
    }

    public enum OpenAppStatus {
        case success
        case busy
        case error
    }

    public func openApp(_ app: Application) async -> OpenAppStatus {
        do {
            setStatus(.opening, for: app.id)
            defer {
                setStatus(.installed, for: app.id)
            }

            let path = "/ext/apps/\(app.category.name)/\(app.alias).fap"
            logger.info("open app \(app.id) by \(path)")

            try await application.start(path, args: "")
            logger.info("open app success")
            return .success
        } catch {
            logger.error("open app: \(error)")
            if
                let appError = error as? Peripheral.Error,
                appError == .application(.systemLocked)
            {
                return .busy
            } else {
                return .error
            }
        }
    }

    private func getFlipperTarget() async throws -> String {
        var target: String = ""
        for try await next in await system.property("devinfo.hardware.target") {
            target = next.value
        }
        return "f\(target)"
    }

    private func getFlipperAPI() async throws -> String {
        var major: String = "0"
        var minor: String = "0"
        for try await next in await system.property("devinfo.firmware.api") {
            switch next.key {
            case "firmware.api.major": major = next.value
            case "firmware.api.minor": minor = next.value
            default: logger.error("unexpected api property")
            }
        }
        return "\(major).\(minor)"
    }

    private func handlingWebErrors<T>(
        _ body: () async throws -> T
    ) async rethrows -> T {
        do {
            return try await body()
        } catch let error as Catalog.CatalogError where error.isUnknownSDK {
            logger.error("apps: unknown sdk")
            isOutdatedDevice = true
            throw Error.unknownSDK
        } catch let error as Catalog.CatalogError where error.httpCode == 404 {
            logger.error("apps: not found")
            throw Error.notFound
        } catch let error as URLError where error.code == .cancelled {
            logger.error("web: \(error)")
            throw Error.canceled
        } catch let error as URLError {
            logger.error("web: \(error)")
            throw Error.noInternet
        } catch {
            logger.error("web: \(error)")
            throw error
        }
    }

    private func mapApp(from app: Catalog.Application) -> Application {
        .init(application: app, category: category(id: app.categoryId))
    }

    private func category(id: String) -> Application.Category {
        guard let category = categories.first(where: { $0.id == id }) else {
            return .unknown
        }
        return .init(category: category)
    }

    private func category(name: String) -> Application.Category {
        guard let category = categories.first(where: { $0.name == name }) else {
            return .init(name: name)
        }
        return .init(category: category)
    }

    private var categoriesTask: Task<[Category], Swift.Error>?

    public func loadCategories() async throws -> [Category] {
        do {
            if let task = categoriesTask {
                return try await task.value
            } else {
                let task = Task<[Category], Swift.Error> {
                    try await handlingWebErrors {
                        try await catalog
                            .categories()
                            .target(deviceInfo?.target)
                            .api(deviceInfo?.api)
                            .get()
                    }
                    .map { .init($0) }
                }
                categoriesTask = task
                categories = try await task.value
                categoriesTask = nil
                return categories
            }
        } catch {
            categoriesTask = nil
            throw error
        }
    }

    public func loadApplications(
        for category: Category? = nil,
        sort sortOption: SortOption = .newUpdates,
        skip: Int = 0,
        take: Int = 7
    ) async throws -> [Application] {
        try await handlingWebErrors {
            try await catalog
                .applications()
                .category(category?.id)
                .sort(by: .init(source: sortOption))
                .order(.init(source: sortOption))
                .target(deviceInfo?.target)
                .api(deviceInfo?.api)
                .skip(skip)
                .take(take)
                .get()
        }
        .map { mapApp(from: $0) }
    }

    public func loadApplication(id: String) async throws -> Application {
        mapApp(from: try await handlingWebErrors {
            try await catalog
                .application(uid: id)
                .target(deviceInfo?.target)
                .api(deviceInfo?.api)
                .get()
        })
    }

    public func search(for string: String) async throws -> [Application] {
        try await handlingWebErrors {
            try await catalog
                .applications()
                .filter(string)
                .target(deviceInfo?.target)
                .api(deviceInfo?.api)
                .take(500)
                .get()
        }
        .map { mapApp(from: $0) }
    }

    private func reloadCategoriesIfNeeded() async {
        if categories.isEmpty, categoriesTask == nil  {
            _ = try? await loadCategories()
        }
    }

    public func loadInstalled() async throws {
        do {
            guard let deviceInfo else { return }
            await reloadCategoriesIfNeeded()

            guard installedStatus != .loading else { return }
            installedStatus = .loading

            let updater = Task {
                await runUpdater(deviceInfo: deviceInfo)
            }

            installed = []
            statuses = [:]
            for await app in try await flipperApps.load() {
                await appendInstalled(app)
            }

            sortInstalled()

            if installedStatus == .loading {
                installedStatus = .loaded
            }

            await updater.value
        } catch {
            installedStatus = .error
            await installed.forEach {
                setStatus(await offlineStatus(for: $0), for: $0.id)
            }
            logger.error("load installed: \(error)")
        }
    }

    private func appendInstalled(_ app: Application) async {
        // TODO: Cache categories to show without internet connection
        var app = app
        app.category = category(name: app.category.name)
        installed.append(app)
        if categories.isEmpty {
            setStatus(await offlineStatus(for: app), for: app.id)
        } else {
            setStatus(.checking, for: app.id)
        }
    }

    private func runUpdater(deviceInfo: DeviceInfo) async {
        var checking: [Application] {
            installed.filter { statuses[$0.id] == .checking }
        }

        let step = 42
        while installedStatus == .loading || !checking.isEmpty {
            let slice = checking.prefix(step)

            guard !slice.isEmpty else {
                try? await Task.sleep(milliseconds: 10)
                continue
            }

            do {
                let loaded = try await catalog
                    .applications()
                    .uids(slice.map(\.id))
                    .target(deviceInfo.target)
                    .api(deviceInfo.api)
                    .take(slice.count)
                    .get()
                    .map { mapApp(from: $0) }

                loaded
                    .filter { $0.category != .unknown }
                    .forEach { updateInstalledApp($0) }

                let missing = slice
                    .filter { !loaded.map(\.id).contains($0.id) }

                await loaded
                    .forEach { setStatus(await status(for: $0), for: $0.id) }
                missing
                    .forEach { setStatus(.building, for: $0.id) }
            } catch {
                await slice.forEach {
                    setStatus(await offlineStatus(for: $0), for: $0.id)
                }
                installedStatus = .error
            }

            sortInstalled()
        }
    }

    private func updateInstalledApp(_ app: Application) {
        if let index = installed.firstIndex(where: { $0.id == app.id }) {
            installed[index] = app
        }
    }

    private func sortInstalled() {
        Task { @MainActor in
            installed = installed.sorted {
                guard
                    let priority0 = statuses[$0.id]?.priotiry,
                    let priority1 = statuses[$1.id]?.priotiry
                else {
                    return false
                }
                guard priority0 != priority1 else {
                    return $0.current.name < $1.current.name
                }
                return priority0 < priority1
            }
        }
    }

    public enum ApplicationStatus: Equatable {
        case installing(Double)
        case updating(Double)
        case notInstalled
        case installed
        case outdated
        case building
        case checking
        case opening

        public var priotiry: Int {
            switch self {
            case .installing(let value) where value > 0: return 1
            case .installing: return 2
            case .updating(let value) where value > 0: return 3
            case .updating: return 4
            case .notInstalled: return 5
            case .outdated: return 6
            case .installed, .opening: return 7
            case .building: return 8
            case .checking: return 9
            }
        }
    }

    public var hasOpenAppSupport: Bool {
        flipper?.hasOpenAppSupport ?? false
    }

    private func status(
        for application: Application
    ) async -> ApplicationStatus {
        // FIXME:
        guard let manifest = await flipperApps.manifests[application.id] else {
            return .notInstalled
        }
        guard
            manifest.versionUID == application.current.id,
            manifest.buildAPI == application.current.build?.sdk.api
        else {
            return application.current.status == .ready
                ? .outdated
                : .building
        }
        return .installed
    }

    private func offlineStatus(
        for application: Application
    ) async -> ApplicationStatus {
        // FIXME:
        guard let manifest = await flipperApps.manifests[application.id] else {
            return .notInstalled
        }
        guard
            let installedMajor = manifest.buildAPI.split(separator: ".").first,
            let flipperMajor = deviceInfo?.api.split(separator: ".").first,
            installedMajor == flipperMajor
        else {
            return .building
        }

        return .installed
    }

    public func report(
        _ application: Application,
        description: String
    ) async throws {
        do {
            try await catalog.report(
                uid: application.id,
                description: description)
        } catch {
            logger.error("report concern: \(error)")
            throw error
        }
    }
}

extension Catalog.SortBy {
    init(source: Applications.SortOption) {
        switch source {
        case .newUpdates, .oldUpdates: self = .updated
        case .newReleases, .oldReleases: self = .created
        }
    }
}

extension Catalog.SortOrder {
    init(source: Applications.SortOption) {
        switch source {
        case .newUpdates, .newReleases: self = .desc
        case .oldUpdates, .oldReleases: self = .asc
        }
    }
}

// MARK: MVP1 🙈

fileprivate extension Applications {
    func _install(
        _ application: Application,
        progress: (Double) -> Void
    ) async throws {
        guard let deviceInfo else {
            return
        }

        let data = try await catalog.build(forVersionID: application.current.id)
            .target(deviceInfo.target)
            .api(deviceInfo.api)
            .get()

        try await flipperApps.install(
            application: application,
            bundle: data,
            progress: progress)
    }
}

extension Applications.Manifest {
    init(
        application: Application,
        isDevCatalog: Bool
    ) async throws {
        guard case .url(let iconURL) = application.current.icon else {
            throw Applications.Error.invalidIcon
        }
        let (icon, _) = try await URLSession.shared.data(from: iconURL)

        guard let build = application.current.build else {
            throw Applications.Error.invalidBuild
        }

        let path: Path = .appPath(
            alias: application.alias,
            category: application.category.name)

        self.init(
            fullName: application.current.name,
            icon: icon,
            buildAPI: build.sdk.api,
            uid: application.id,
            versionUID: application.current.id,
            path: path.string,
            isDevCatalog: isDevCatalog
        )
    }
}

extension Applications.Manifest {
    var alias: String? {
        guard
            let name = path.split(separator: "/").last,
            let alias = name.split(separator: ".").first
        else {
            return nil
        }
        return .init(alias)
    }
}

extension Flipper {
    var hasAPIVersion: Bool {
        guard
            let protobuf = information?.protobufRevision,
            protobuf >= .v0_17
        else {
            return false
        }
        return true
    }

    var hasOpenAppSupport: Bool {
        guard
            let protobuf = information?.protobufRevision,
            protobuf >= .v0_18
        else {
            return false
        }
        return true
    }
}

extension Sequence {
    @inlinable public func forEach(
        _ body: (Element) async throws -> Void
    ) async rethrows {
        for item in self {
            try await body(item)
        }
    }
}
