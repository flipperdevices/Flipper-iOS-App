import Peripheral

import Foundation

actor FlipperApps {
    private let storage: StorageAPI
    private let cache: Cache

    typealias Manifest = Applications.Manifest

    var manifests: [Application.ID: Manifest] = [:]

    var isDevCatalog: Bool {
        UserDefaultsStorage.shared.isDevCatalog
    }

    init(storage: StorageAPI, cache: Cache) {
        self.storage = storage
        self.cache = cache
    }

    private var cachedListing: [Path: [File]] = [:]
    private var cachedManifests: [Path: Hash] = [:]

    func load() async throws -> AsyncStream<Application> {
        cachedListing = [:]
        cachedManifests = try await cache.getManifest().items

        let manifests = try await loadManifests()
        return .init { continuation in
            let task = Task {
                for await manifest in manifests.filter(validate) {
                    self.manifests[manifest.uid] = manifest
                    if let application = Application(manifest) {
                        continuation.yield(application)
                    }
                }
                continuation.finish()
            }
            continuation.onTermination = {
                if $0 == .cancelled {
                    task.cancel()
                }
            }
        }
    }

    @Sendable
    private func validate(_ manifest: Manifest) async -> Bool {
        guard validateCatalogPreference(manifest) else { return false }
        guard await validateAppExists(manifest) else { return false }
        return true
    }

    // filter by current catalog preference
    private func validateCatalogPreference(_ manifest: Manifest) -> Bool {
        manifest.isDevCatalog == isDevCatalog
    }

    // filter invalid/deleted apps
    private func validateAppExists(_ manifest: Manifest) async -> Bool {
        do {
            let appPath = Path(string: manifest.path)
            let appFileName = appPath.lastComponent
            let appDirectory = appPath.removingLastComponent
            if cachedListing[appDirectory] == nil {
                cachedListing[appDirectory] = try await storage
                    .list(at: appDirectory)
                    .files
            }
            return cachedListing[appDirectory, default: []]
                .contains { $0.name == appFileName }
        } catch {
            logger.error("validate app exists: \(error)")
            return false
        }
    }

    private func listManifests() async -> [File] {
        do {
            return try await storage.list(
                at: .appsManifests,
                calculatingMD5: true
            )
            .files
            .filter({ $0.name.hasSuffix(".fim") })
            .filter({ !$0.name.hasPrefix(".") })
        } catch {
            logger.error("list manifests: \(error)")
            return []
        }
    }

    private func loadManifests() async throws -> AsyncStream<Manifest> {
        .init { continuation in
            let task = Task {
                for file in await listManifests() {
                    do {
                        continuation.yield(try await loadManifest(file))
                    } catch {
                        logger.error("load manifest: \(error)")
                    }
                }
                continuation.finish()
            }
            continuation.onTermination = { termination in
                if termination == .cancelled {
                    task.cancel()
                }
            }
        }
    }

    private func loadManifest(_ file: File) async throws -> Manifest {
        let path: Path = .appsManifests.appending(file.name)
        let hash = Hash(file.md5)
        if !hash.value.isEmpty, cachedManifests[path] == hash {
            return try await cachedManifest(path)
        } else {
            return try await remoteManifest(path)
        }
    }

    private func remoteManifest(_ path: Path) async throws -> Manifest {
        let data = try await storage.read(at: path)
        try await cache.upsert(String(decoding: data, as: UTF8.self), at: path)
        let manifest = try FFFDecoder.decode(Manifest.self, from: data)
        return manifest
    }

    private func cachedManifest(_ path: Path) async throws -> Manifest {
        let data = try await cache.read(path)
        let manifest = try FFFDecoder.decode(Manifest.self, from: data)
        return manifest
    }

    func install(
        application: Application,
        bundle: Data,
        progress: (Double) -> Void
    ) async throws {
        let category = application.category
        try? await storage.createDirectory(at: .temp)
        try? await storage.createDirectory(at: .iosTemp)

        try? await storage.createDirectory(at: .apps)
        try? await storage.createDirectory(at: .categoryPath(category.name))
        try? await storage.createDirectory(at: .appsManifests)

        let appTempPath: Path = .tempAppPath(
            alias: application.alias)
        let manifestTempPath: Path = .tempAppManifestPath(
            alias: application.alias)

        let appPath: Path = .appPath(
            alias: application.alias,
            category: category.name)
        let manifestPath: Path = .appManifestPath(
            alias: application.alias)

        try await storage.write(
            at: appTempPath,
            bytes: .init(bundle)
        ) { writeProgress in
            progress(writeProgress)
        }

        let manifest = try await Applications.Manifest(
            application: application,
            isDevCatalog: isDevCatalog
        )

        let manifestString = try FFFEncoder.encode(manifest)

        try await storage.write(
            at: manifestTempPath,
            string: manifestString
        ) { _ in
        }

        try await storage.move(at: appTempPath, to: appPath)
        try await storage.move(at: manifestTempPath, to: manifestPath)

        manifests[application.id] = manifest
        try await cache.upsert(manifestString, at: manifestPath)
    }

    func delete(_ id: Application.ID) async throws {
        guard let manifest = manifests[id] else {
            return
        }

        guard let alias = manifest.alias else {
            return
        }

        let appPath: Path = .init(string: manifest.path)
        let manifestPath: Path = .appManifestPath(alias: alias)

        try await storage.delete(at: appPath)
        try await storage.delete(at: manifestPath)

        manifests[id] = nil
        try await cache.delete(manifestPath)
    }
}

extension Path {
    static let temp: Path = "/ext/.tmp"
    static var iosTemp: Path { "\(temp)/ios" }

    static var apps: Path { "/ext/apps" }
    static var appsManifests: Path { "/ext/apps_manifests" }

    static func categoryPath(_ category: String) -> Path {
        .apps.appending(category)
    }

    static func appPath(alias: String, category: String) -> Path {
        .categoryPath(category).appending("\(alias).fap")
    }

    static func appManifestPath(alias: String) -> Path {
        .appsManifests.appending("\(alias).fim")
    }

    static func tempAppPath(alias: String) -> Path {
        .iosTemp.appending("\(alias).fap")
    }

    static func tempAppManifestPath(alias: String) -> Path {
        .iosTemp.appending("\(alias).fim")
    }
}
