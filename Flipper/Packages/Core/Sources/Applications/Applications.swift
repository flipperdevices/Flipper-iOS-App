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
    @Published public var manifests: [Application.ID: Manifest] = [:]
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
        case noInternet
    }

    private var rpc: RPC { pairedDevice.session }
    @Published private var flipper: Flipper?
    private var cancellables = [AnyCancellable]()


    private let catalog: CatalogService
    private let pairedDevice: PairedDevice

    public init(catalog: CatalogService, pairedDevice: PairedDevice) {
        self.catalog = catalog
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

    func onFlipperChanged(_ oldValue: Flipper?) {
        if oldValue?.state != .connected, flipper?.state == .connected {
            Task {
                manifests = try await _loadManifests()
                deviceInfo = try await getDeviceInfo()
            }
        } else if oldValue?.state == .connected, flipper?.state != .connected {
            manifests = [:]
            deviceInfo = nil
            statuses = [:]
        }
    }

    private func getDeviceInfo() async throws -> DeviceInfo {
        let target = try await getFlipperTarget()
        let api = try await getFlipperAPI()
        return .init(target: target, api: api)
    }

    private func demoDelay() async {
        try? await Task.sleep(seconds: 1)
    }

    public func install(_ application: Application) {
        Task {
            do {
                statuses[application.id] = .installing(0)
                try await _install(application) { progress in
                    Task {
                        statuses[application.id] = .installing(progress)
                    }
                }
                statuses[application.id] = nil
            } catch {
                logger.error("install app: \(error)")
            }
        }
    }

    public func update(_ application: Application) {
        Task {
            do {
                statuses[application.id] = .updating(0)
                try await _install(application) { progress in
                    Task {
                        statuses[application.id] = .updating(progress)
                    }
                }
                statuses[application.id] = nil
            } catch {
                logger.error("update app: \(error)")
            }
        }
    }

    public func delete(_ application: Application) {
        Task {
            do {
                try await _delete(application)
            } catch {
                logger.error("delete app: \(error)")
            }
        }
    }

    public func category(for application: Application) -> Category? {
        guard !application.categoryId.isEmpty else {
            let name = categoryName(for: application)
            return categories.first { $0.name == name }
        }
        return categories.first { $0.id == application.categoryId }
    }

    public func categoryName(for application: Application) -> String {
        guard application.categoryId.isEmpty else {
            return category(for: application)?.name ?? "unknown"
        }
        guard let manifest = manifests[application.id] else {
            return "unknown"
        }
        let parts = manifest.path.split(separator: "/")
        guard parts.count == 4 else {
            return "unknown"
        }
        return .init(parts[2])
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
                    try await catalog.categories().get()
                }
                categoriesTask = nil
                return categories
            }
            return try await task.value
        }
    }

    public func loadApplications(
        for category: Category? = nil,
        sort sortOption: SortOption = .newUpdates
    ) async throws -> [Application] {
        try await handlingWebErrors {
            try await catalog
                .applications()
                .category(category?.id)
                .sort(by: .init(source: sortOption))
                .order(.init(source: sortOption))
                .target(deviceInfo?.target)
                .api(deviceInfo?.api)
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

    public func search(for predicate: String) async throws -> [Application] {
        try await handlingWebErrors {
            try await catalog
                .applications()
                .filter(predicate)
                .target(deviceInfo?.target)
                .api(deviceInfo?.api)
                .get()
        }
    }

    public func loadInstalled() async throws -> [Application] {
        let installed = manifests.compactMap {
            Application($0.value)
        }
        guard let deviceInfo else {
            return installed
        }

        let available = try await catalog
            .applications()
            .uids(installed.map { $0.id })
            .target(deviceInfo.target)
            .api(deviceInfo.api)
            .get()

        for application in available {
            statuses[application.id] = status(for: application)
        }

        return installed
    }

    public enum ApplicationStatus: Equatable {
        case installing(Double)
        case updating(Double)
        case notInstalled
        case installed
        case outdated
        case unknown
    }

    public func status(
        for application: Application
    ) -> ApplicationStatus {
        guard statuses[application.id] == nil else {
            return statuses[application.id] ?? .unknown
        }
        guard let manifest = manifests[application.id] else {
            return .notInstalled
        }
        guard
            manifest.versionUID == application.current.id,
            manifest.buildAPI == deviceInfo?.api
        else {
            return .outdated
        }
        return .installed
    }

    public func report(
        _ application: Application,
        description: String
    ) async throws {
        try await catalog.report(uid: application.id, description: description)
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
        case .newUpdates, .newReleases: self = .asc
        case .oldUpdates, .oldReleases: self = .desc
        }
    }
}

// MARK: MVP0 🙈

fileprivate extension Applications {
    var tempPath: Path { "/ext/.tmp" }
    var iosTempPath: Path { "\(tempPath)/ios" }

    var appsPath: Path { "/ext/apps" }
    var manifestsPath: Path { "/ext/apps_manifests" }

    func _install(
        _ application: Application,
        progress: (Double) -> Void
    ) async throws {
        var application = application
        if application.current.build?.sdk.api == nil {
            application = try await loadApplication(id: application.id)
        }

        let target = try await getFlipperTarget()
        let api = try await getFlipperAPI()

        let data = try await catalog.build(forVersionID: application.current.id)
            .target(target)
            .api(api)
            .get()

        try? await rpc.createDirectory(at: tempPath)
        try? await rpc.createDirectory(at: iosTempPath)

        guard let category = category(for: application) else {
            return
        }
        let appCategoryPath: Path = "\(appsPath)/\(category.name)"

        try? await rpc.createDirectory(at: appsPath)
        try? await rpc.createDirectory(at: appCategoryPath)
        try? await rpc.createDirectory(at: manifestsPath)

        let appName = "\(application.alias).fap"
        let manifestName = "\(application.alias).fim"

        let appTempPath: Path = "\(iosTempPath)/\(appName)"
        let manifestTempPath: Path = "\(iosTempPath)/\(manifestName)"

        let appPath: Path = "\(appCategoryPath)/\(appName)"
        let manifestPath: Path = "\(manifestsPath)/\(manifestName)"

        try await rpc.writeFile(
            at: appTempPath,
            bytes: .init(data)
        ) { writeProgress in
            progress(writeProgress)
        }

        guard case .url(let iconURL) = application.current.icon else {
            return
        }
        let (icon, _) = try await URLSession.shared.data(from: iconURL)

        let manifest = Applications.Manifest(
            fullName: application.current.name,
            icon: icon,
            buildAPI: application.current.build?.sdk.api ?? "",
            uid: application.id,
            versionUID: application.current.id,
            path: appPath.string)

        let manifestString = try FFFEncoder.encode(manifest)

        try await rpc.writeFile(
            at: manifestTempPath,
            string: manifestString
        ) { progress in
            logger.info("writing manifest \(progress)")
        }

        try await rpc.moveFile(from: appTempPath, to: appPath)
        try await rpc.moveFile(from: manifestTempPath, to: manifestPath)

        manifests[application.id] = manifest
    }

    func _delete(_ application: Application) async throws {
        guard let category = category(for: application) else {
            return
        }
        let appCategoryPath: Path = "\(appsPath)/\(category.name)"
        let appName = "\(application.alias).fap"
        let manifestName = "\(application.alias).fim"
        let appPath: Path = "\(appCategoryPath)/\(appName)"
        let manifestPath: Path = "\(manifestsPath)/\(manifestName)"

        try await rpc.deleteFile(at: appPath)
        try await rpc.deleteFile(at: manifestPath)

        manifests[application.id] = nil
        statuses[application.id] = nil
    }
}

extension Applications {
    func _loadManifests() async throws -> [Application.ID: Manifest] {
        var result: [Application.ID: Manifest] = [:]
        guard
            let listing = try? await rpc.listDirectory(at: manifestsPath)
        else {
            return result
        }
        for file in listing.files {
            do {
                let manifest = try await _loadManifest(file)
                result[manifest.uid] = manifest
            } catch {
                logger.error("load manifest: \(error)")
            }
        }
        return result
    }

    func _loadManifest(_ name: String) async throws -> Manifest {
        let data = try await rpc.readFile(at: "\(manifestsPath)/\(name)")
        let manifest = try FFFDecoder.decode(Manifest.self, from: data)
        return manifest
    }
}
