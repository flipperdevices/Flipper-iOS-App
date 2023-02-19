import Peripheral

import Foundation

public class Update {
    public struct Version: Equatable {
        public var channel: Channel
        public var firmware: Manifest.Version

        public init(channel: Channel, firmware: Manifest.Version) {
            self.channel = channel
            self.firmware = firmware
        }
    }

    public struct Manifest: Decodable {
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

    public enum Channel: Equatable {
        case development
        case candidate
        case release
        case custom(URL)
    }

    public struct Intent: Equatable, Identifiable {
        public let id: Int
        public let from: Version
        public let to: Version

        public init(id: Int, from: Version, to: Version) {
            self.id = id
            self.from = from
            self.to = to
        }
    }

    public enum Error: Swift.Error {
        case invalidFirmware
        case invalidFirmwareURL
        case invalidFirmwareURLString
        case invalidFirmwareCloudDocument
    }
}

extension Update.Version: CustomStringConvertible {
    public var description: String {
        switch channel {
        case .development: return "Dev \(firmware.version)"
        case .candidate: return "RC \(firmware.version.dropLast(3))"
        case .release: return "Release \(firmware.version)"
        case .custom(let url): return "Custom \(url.lastPathComponent)"
        }
    }

    public init(channel: Update.Channel, version: String) {
        self.init(
            channel: channel,
            firmware: .init(
                version: version,
                changelog: "",
                timestamp: 0,
                files: []
            )
        )
    }
}

extension Update.Channel: RawRepresentable {
    public var rawValue: String {
        switch self {
        case .release: return "release"
        case .candidate: return "canditate"
        default: return "development"
        }
    }

    public init(rawValue: String) {
        switch rawValue {
        case "release": self = .release
        case "canditate": self = .candidate
        default: self = .development
        }
    }
}
