import Peripheral

protocol AppsManifests {
    typealias Manifest = Applications.Manifest

    func loadManifests() async throws -> [Manifest]
}
