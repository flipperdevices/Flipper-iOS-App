public protocol TargetManifestSource {
    func manifest(
        for target: Update.Target,
        progress: @escaping (Double) -> Void
    ) async throws -> Update.Manifest
}

extension TargetManifestSource {
    func manifest(for target: Update.Target) async throws -> Update.Manifest {
        try await manifest(for: target) { _ in }
    }
}

// MARK: Remote

class RemoteTargetManifestSource: TargetManifestSource {
    let manifestSource: FirmwareManifestSource

    init(manifestSource: FirmwareManifestSource) {
        self.manifestSource = manifestSource
    }

    func manifest(
        for target: Update.Target,
        progress: @escaping (Double) -> Void
    ) async throws -> Update.Manifest {
        let manifest = try await manifestSource.get(progress: progress)
        return try .init(for: target, from: manifest)
    }
}
