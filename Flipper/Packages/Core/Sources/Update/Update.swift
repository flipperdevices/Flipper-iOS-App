import Foundation

public enum Update {
    public struct Firmware: Equatable {
        public var version: Version
        public var changelog: String
        public var url: URL
    }

    public struct Version: Equatable {
        public let name: String
        public let channel: Channel
    }

    public enum Channel: String, Equatable {
        case development
        case candidate
        case release
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
        }
    }
}

extension Update.Version: CustomStringConvertible {
    public var description: String {
        switch channel {
        case .development: return "Dev \(name)"
        case .candidate: return "RC \(name.dropLast(3))"
        case .release: return "Release \(name)"
        }
    }
}
