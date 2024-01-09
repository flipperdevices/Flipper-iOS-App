import Macro
import Catalog
import Peripheral

import Logging
import Combine
import Foundation

@MainActor
public class Applications: ObservableObject {
    public typealias Category = Catalog.Category
    public typealias Application = Catalog.Application

    private var categories: [Category] = []

    public enum InstalledStatus {
        case loading
        case loaded
        case error
    }

    @Published public var installed: [Application] = []
    @Published public var installedStatus: InstalledStatus = .error
    @Published public var statuses: [Application.ID: ApplicationStatus] = [:]

    public var outdatedCount: Int {
        statuses
            .map { $0.value }
            .filter { $0 == .outdated }
            .count
    }

    public enum SortOption: String, CaseIterable {
        case newUpdates = "New Updates"
        case newReleases = "New Releases"
        case oldUpdates = "Old Updates"
        case oldReleases = "Old Releases"

        public static var `default`: SortOption { .newUpdates }
    }

    public enum Error: Swift.Error {
        case notFound
        case noInternet
        case unknownSDK
        case invalidIcon
        case invalidBuild
    }

    private var rpc: RPC { pairedDevice.session }
    @Published private var flipper: Flipper?
    private var cancellables = [AnyCancellable]()

    private let catalog: CatalogService
    private let pairedDevice: PairedDevice

    private let flipperApps: FlipperApps

    init(
        catalog: CatalogService,
        flipperApps: FlipperApps,
        pairedDevice: PairedDevice
    ) {
        self.catalog = catalog
        self.flipperApps = flipperApps
        self.pairedDevice = pairedDevice

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

    public func install(_ application: Application) async {
        do {
            statuses[application.id] = .installing(0)
            try await _install(application) { progress in
                Task {
                    statuses[application.id] = .installing(progress)
                }
            }
            statuses[application.id] = installedAppStatus()
        } catch {
            logger.error("install app: \(error)")
        }
    }

    public func update(_ application: Application) async {
        do {
            statuses[application.id] = .updating(0)
            try await _install(application) { progress in
                Task {
                    statuses[application.id] = .updating(progress)
                }
            }
            statuses[application.id] = installedAppStatus()
        } catch {
            logger.error("update app: \(error)")
        }
    }

    public func update(_ applications: [Application]) async {
        for application in applications {
            statuses[application.id] = .updating(0)
        }
        for application in applications {
            await update(application)
        }
    }

    public func delete(_ id: Application.ID) async {
        do {
            try await flipperApps.delete(id)
            installed.removeAll { $0.id == id }
            statuses[id] = nil
        } catch {
            logger.error("delete app: \(error)")
        }
    }

    public enum OpenAppStatus {
        case success
        case busy
        case error
    }

    public func openApp(
        by id: Application.ID,
        callback: (OpenAppStatus) -> Void
    ) async {
        do {
            statuses[id] = .opening
            defer {
                statuses[id] = .canOpen
            }

            guard
                let category = category(installedID: id),
                let app = installed.first(where: { $0.id == id })
            else { return }

            let path = "/ext/apps/\(category.name)/\(app.alias).fap"
            logger.info("open app \(id) by \(path)")

            try await rpc.appStart(path, args: "RPC")
            logger.info("open app success")
            callback(.success)
        } catch {
            logger.error("open app: \(error)")
            if
                let appError = error as? Peripheral.Error,
                    appError == .application(.systemLocked) {
                callback(.busy)
            }
            else {
                callback(.error)
            }
        }
    }

    public func category(for application: Application) -> Category? {
        application.categoryId.isEmpty
            ? category(installedID: application.id)
            : category(categoryID: application.categoryId)
    }

    private func category(categoryID id: String) -> Category? {
        return categories.first { $0.id == id }
    }

    private func category(installedID id: Application.ID) -> Category? {
        let name = flipperApps.category(forInstalledId: id)
        return categories.first(where: { $0.name == name })
    }

    private func getFlipperTarget() async throws -> String {
        var target: String = ""
        for try await property in rpc.property("devinfo.hardware.target") {
            target = property.value
        }
        return "f\(target)"
    }

    private func getFlipperAPI() async throws -> String {
        var major: String = "0"
        var minor: String = "0"
        for try await property in rpc.property("devinfo.firmware.api") {
            switch property.key {
            case "firmware.api.major": major = property.value
            case "firmware.api.minor": minor = property.value
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
        } catch let error as URLError {
            logger.error("web: \(error)")
            throw Error.noInternet
        } catch {
            logger.error("web: \(error)")
            throw error
        }
    }

    public func loadTopApp() async throws -> Application {
        try await handlingWebErrors {
            _ = try await loadCategories()
            guard let app = try await catalog.featured().get().first else {
                throw Error.noInternet
            }
            return app
        }
    }

    private var categoriesTask: Task<[Category], Swift.Error>?

    public func loadCategories() async throws -> [Category] {
        if let task = categoriesTask {
            return try await task.value
        } else {
            let task = Task<[Category], Swift.Error> {
                categories = try await handlingWebErrors {
                    try await catalog
                        .categories()
                        .target(deviceInfo?.target)
                        .api(deviceInfo?.api)
                        .get()
                }
                categoriesTask = nil
                return categories
            }
            return try await task.value
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
    }

    public func loadApplication(id: String) async throws -> Application {
        try await handlingWebErrors {
            try await catalog
                .application(uid: id)
                .target(deviceInfo?.target)
                .api(deviceInfo?.api)
                .get()
        }
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
    }

    public func loadInstalled() async throws {
        do {
            guard let deviceInfo else { return }

            guard installedStatus != .loading else { return }
            installedStatus = .loading

            installed = try await flipperApps.load()
            installed.forEach { statuses[$0.id] = .checking }

            let step = 42
            for processed in stride(from: 0, to: installed.count, by: step)  {
                let slice = installed.dropFirst(processed).prefix(step)

                let loaded = try await catalog
                    .applications()
                    .uids(slice.map { $0.id })
                    .target(deviceInfo.target)
                    .api(deviceInfo.api)
                    .take(slice.count)
                    .get()

                loaded
                    .forEach { updateInstalledApp($0) }

                let missing = slice
                    .filter { !loaded.map(\.id).contains($0.id) }

                loaded
                    .forEach { statuses[$0.id] = status(for: $0) }
                missing
                    .forEach { statuses[$0.id] = .building }
            }

            installedStatus = .loaded
        } catch {
            installedStatus = .error
            installed.forEach { statuses[$0.id] = installedAppStatus() }
            logger.error("load installed: \(error)")
        }
    }

    func updateInstalledApp(_ app: Application) {
        if let index = installed.firstIndex(where: { $0.id == app.id }) {
            installed[index] = app
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
        case canOpen
        case opening
    }

    private func installedAppStatus() -> ApplicationStatus {
        flipper?.hasOpenAppSupport == true ? .canOpen : .installed
    }

    private func status(
        for application: Application
    ) -> ApplicationStatus {
        // FIXME:
        guard let manifest = flipperApps.manifests[application.id] else {
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
        return installedAppStatus()
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

extension Catalog.Category: Identifiable {}
extension Catalog.Application: Identifiable {}

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

        if !installed.contains(where: { $0.id == application.id }) {
            installed.append(application)
        }

        let data = try await catalog.build(forVersionID: application.current.id)
            .target(deviceInfo.target)
            .api(deviceInfo.api)
            .get()

        guard let category = category(for: application) else {
            return
        }

        try await flipperApps.install(
            application: application,
            category: category,
            bundle: data,
            progress: progress)
    }
}

extension Applications.Manifest {
    init(
        application: Catalog.Application,
        category: Catalog.Category,
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
            category: category.name)

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
