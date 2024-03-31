import Catalog
import Peripheral

import Foundation

class FlipperApps {
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

    func load() async throws -> AsyncStream<Application> {
        let manifests = try await loadManifests()
        return .init { continuation in
            let task = Task {
                for await manifest in manifests {
                    guard manifest.isDevCatalog == isDevCatalog else {
                        continue
                    }
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

    func category(forInstalledId id: Application.ID) -> String? {
        guard let manifest = manifests[id] else {
            return nil
        }
        let parts = manifest.path.split(separator: "/")
        guard parts.count == 4 else {
            return nil
        }
        return String(parts[2])
    }

    private func listManifests() async throws -> [File] {
        try await storage.list(
            at: .appsManifests,
            calculatingMD5: true
        )
        .files
        .filter({ $0.name.hasSuffix(".fim") })
        .filter({ !$0.name.hasPrefix(".") })
    }

    private func loadManifests() async throws -> AsyncStream<Manifest> {
        let cached = try await cache.manifest

        return .init { continuation in
            let task = Task {
                for file in try await listManifests() {
                    do {
                        let path: Path = .appsManifests.appending(file.name)
                        let hash = Hash(file.md5)
                        if !hash.value.isEmpty, cached.items[path] == hash {
                            continuation.yield(try await cachedManifest(path))
                        } else {
                            continuation.yield(try await remoteManifest(path))
                        }
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

    func remoteManifest(_ path: Path) async throws -> Manifest {
        let data = try await storage.read(at: path)
        try await cache.upsert(String(decoding: data, as: UTF8.self), at: path)
        let manifest = try FFFDecoder.decode(Manifest.self, from: data)
        return manifest
    }

    func cachedManifest(_ path: Path) async throws -> Manifest {
        let data = try await cache.get(path)
        let manifest = try FFFDecoder.decode(Manifest.self, from: data)
        return manifest
    }

    func install(
        application: Application,
        category: Catalog.Category,
        bundle: Data,
        progress: (Double) -> Void
    ) async throws {
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
            category: category,
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
