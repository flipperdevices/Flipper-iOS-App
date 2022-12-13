import Inject
import Analytics
import Peripheral

import Foundation
import Logging

public struct Update {
    let logger = Logger(label: "update")
    @Inject var rpc: RPC

    public var state: State = .update(.preparing)

    public enum State: Equatable {
        case update(Update)
        case error(Error)

        public enum Update: Equatable {
            case preparing
            case downloading(progress: Double)
            case uploading(progress: Double)
            case started
            case canceling
        }

        public enum Error: Equatable {
            case cantConnect
            case noInternet
            case noDevice
            case noCard
            case storageError
            case outdatedApp
            case failedDownloading
            case failedPreparing
            case failedUploading
            case canceled
        }
    }

    public var intent: Intent?
    public var result: Result?

    public struct Version: Equatable, CustomStringConvertible {
        public var channel: Channel
        public var firmware: Manifest.Version

        public var description: String {
            switch channel {
            case .development: return "Dev \(firmware.version)"
            case .candidate: return "RC \(firmware.version.dropLast(3))"
            case .release: return "Release \(firmware.version)"
            case .custom(let url): return "Custom \(url.lastPathComponent)"
            }
        }

        public init(channel: Channel, firmware: Manifest.Version) {
            self.channel = channel
            self.firmware = firmware
        }

        public init(channel: Channel, version: String) {
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

    public enum Result: Sendable {
        case completed
        case canceled
        case failedDownload
        case failedPrepare
        case failedUpload
        case failed
    }

    public enum Error: Swift.Error {
        case invalidFirmware
        case invalidFirmwareURL
        case invalidFirmwareURLString
        case invalidFirmwareCloudDocument
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
