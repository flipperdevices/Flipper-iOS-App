import Catalog
import Peripheral

import Foundation

class FlipperApps {
    private let storage: StorageAPI
    private let cache: Cache

    typealias Manifest = Applications.Manifest

    var manifests: [Application.ID: Manifest] = [:]

    init(storage: StorageAPI, cache: Cache) {
        self.storage = storage
        self.cache = cache
    }

    func load() async throws -> [ApplicationInfo] {
        manifests = try await reloadManifests()

        return manifests.compactMap {
            ApplicationInfo($0.value)
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

    private func reloadManifests() async throws -> [Application.ID: Manifest] {
        var result: [Application.ID: Manifest] = [:]
        try await loadManifests().forEach { manifest in
            result[manifest.uid] = manifest
        }
        return result
    }

    private func loadManifests() async throws -> [Manifest] {
        var result: [Manifest] = []
        let cached = try await cache.manifest

        let listing = try await storage.list(
            at: .appsManifests,
            calculatingMD5: true)

        for file in listing.files.filter({ !$0.name.starts(with: ".") }) {
            do {
                let path: Path = .appsManifests.appending(file.name)
                let hash = Hash(file.md5)
                if let localHash = cached.items[path], localHash == hash {
                    result.append(try await loadLocalManifest(path))
                } else {
                    result.append(try await loadManifest(path))
                }
            } catch {
                logger.error("load manifest: \(error)")
            }
        }

        return result
    }

    func loadManifest(_ path: Path) async throws -> Manifest {
        let data = try await storage.read(at: path)
        try await cache.upsert(String(decoding: data, as: UTF8.self), at: path)
        let manifest = try FFFDecoder.decode(Manifest.self, from: data)
        return manifest
    }

    func loadLocalManifest(_ path: Path) async throws -> Manifest {
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
            category: category)

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
