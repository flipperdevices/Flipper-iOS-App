import Foundation

struct FirmwareManifest: Decodable {
    public let channels: [Channel]

    public struct Channel: Decodable {
        public let id: String
        public let title: String
        public let description: String
        public let versions: [Version]
    }

    public struct Version: Equatable, Decodable {
        public let version: String
        public let changelog: String
        public let timestamp: Int
        public let files: [File]

        public struct File: Equatable, Decodable {
            let url: URL
            let target: String
            let type: String
            let sha256: String
        }
    }
}

extension FirmwareManifest {
    func channel(withID id: String) throws -> FirmwareManifest.Channel {
        guard let channel = channels.first(where: { $0.id == id }) else {
            throw FirmwareManifestError.channelNotFound
        }
        return channel
    }
}

extension FirmwareManifest.Channel {
    func version(forTarget target: String) throws -> FirmwareManifest.Version {
        let versions = versions.sorted { $0.timestamp > $1.timestamp }
        guard let version = versions.first(where: { version in
            (try? version.updateBundle(forTarget: target)) != nil
        }) else {
            throw FirmwareManifestError.targetNotFound
        }
        return version
    }
}

extension FirmwareManifest.Version {
    func updateBundle(forTarget target: String) throws -> File {
        guard let file = files.first(where: {
            $0.target == target && $0.type == "update_tgz"
        }) else {
            throw FirmwareManifestError.bundleNotFound
        }
        return file
    }
}
