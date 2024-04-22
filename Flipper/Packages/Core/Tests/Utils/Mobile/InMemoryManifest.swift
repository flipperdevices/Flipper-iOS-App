@testable import Core
@testable import Peripheral

class InMemoryManifest: ManifestStorage {
    var manifest: Manifest

    init(manifest: Manifest = .init()) {
        self.manifest = manifest
    }

    func get() async throws -> Manifest {
        manifest
    }

    func upsert(_ manifest: Manifest) async throws {
        self.manifest = manifest
    }

    func delete() async throws {
        manifest = .init()
    }
}
