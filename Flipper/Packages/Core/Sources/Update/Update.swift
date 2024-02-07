import Foundation

public enum Update {
    public struct Manifest {
        public let release: Firmware
        public let candidate: Firmware
        public let development: Firmware
    }

    public struct Firmware: Equatable {
        public var version: Version
        public var changelog: String
        public var url: URL

        public init(version: Version, changelog: String, url: URL) {
            self.version = version
            self.changelog = changelog
            self.url = url
        }
    }

    public struct Version: Equatable, Codable {
        public let name: String
        public let channel: Channel

        public init(name: String, channel: Channel) {
            self.name = name
            self.channel = channel
        }
    }

    public enum Channel: String, Equatable, Codable {
        case development
        case candidate
        case release
        case file
        case url
    }

    public enum Target: String {
        case f7
    }

    public enum Error: Swift.Error {
        case invalidFirmware
        case invalidFirmwareURL
        case invalidFirmwareURLString
        case invalidFirmwareCloudDocument
    }

    public struct Intent: Equatable, Identifiable {
        public let id: Int
        public let currentVersion: Version
        public let desiredVersion: Version
    }
}

extension Update.Manifest {
    init(for target: Update.Target, from manifest: FirmwareManifest) throws {
        release = try manifest.firmware(for: target, channel: .release)
        candidate = try manifest.firmware(for: target, channel: .candidate)
        development = try manifest.firmware(for: target, channel: .development)
    }
}

extension FirmwareManifest {
    func firmware(
        for target: Update.Target,
        channel: Update.Channel
    ) throws -> Update.Firmware {
        let version = try self.channel(withID: channel.id)
            .version(forTarget: target.rawValue)

        let url = try version
            .updateBundle(forTarget: target.rawValue)
            .url

        return .init(
            version: .init(
                name: version.version,
                channel: channel),
            changelog: version.changelog,
            url: url)
    }
}

private extension Update.Channel {
    var id: String {
        switch self {
        case .development: return "development"
        case .candidate: return "release-candidate"
        case .release: return "release"
        case .file: return "file"
        case .url: return "url"
        }
    }
}

extension Update.Version: CustomStringConvertible {
    public var description: String {
        switch channel {
        case .development: return "Dev \(name)"
        case .candidate: return "RC \(name.dropLast(3))"
        case .release: return "Release \(name)"
        case .file: return "Custom \(name)"
        case .url: return name
        }
    }
}
