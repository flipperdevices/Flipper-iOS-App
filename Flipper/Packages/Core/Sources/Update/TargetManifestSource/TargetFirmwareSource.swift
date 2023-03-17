public protocol TargetFirmwareSource {
    func firmware(
        for target: Update.Target,
        channel: Update.Channel,
        progress: @escaping (Double) -> Void
    ) async throws -> Update.Firmware
}

extension TargetFirmwareSource {
    func firmware(
        for target: Update.Target,
        channel: Update.Channel
    ) async throws -> Update.Firmware {
        try await firmware(for: target, channel: channel) { _ in }
    }
}

// MARK: Remote

class RemoteTargetFirmwareSource: TargetFirmwareSource {
    let manifestSource: FirmwareManifestSource

    init(manifestSource: FirmwareManifestSource) {
        self.manifestSource = manifestSource
    }

    func firmware(
        for target: Update.Target,
        channel: Update.Channel,
        progress: @escaping (Double) -> Void
    ) async throws -> Update.Firmware {
        let manifest = try await manifestSource.get(progress: progress)
        return try manifest.firmware(for: target, channel: channel)
    }
}
