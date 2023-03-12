import Foundation

protocol FirmwareManifestSource {
    func get(
        progress: @escaping (Double) -> Void
    ) async throws -> FirmwareManifest
}

extension FirmwareManifestSource {
    func get() async throws -> FirmwareManifest {
        try await get { _ in }
    }
}

// MARK: Remote

struct RemoteFirmwareManifestSource: FirmwareManifestSource {
    func get(
        progress: @escaping (Double) -> Void
    ) async throws -> FirmwareManifest {
        let data = URLSessionData(from: .firmwareManifestURL) {
            progress($0.fractionCompleted)
        }
        return try await JSONDecoder().decode(
            FirmwareManifest.self,
            from: data.result
        )
    }
}
