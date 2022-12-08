import Inject
import Peripheral
import Foundation
import Logging

public struct Update {
    let logger = Logger(label: "update")
    @Inject var rpc: RPC

    public var state: State = .loading

    public enum State: Equatable {
        case loading
        case idle(Idle)
        case update(Update)
        case error(Error)

        public enum Idle: Equatable {
            case noUpdates
            case versionUpdate
            case channelUpdate
        }

        public enum Update: Equatable {
            case preparing
            case downloading(progress: Double)
            case uploading(progress: Double)
            case started
            case canceling
        }

        public enum Error: Equatable {
            case noInternet
            case noDevice
            case noCard
            case storageError
            case failedDownloading
            case failedPreparing
            case failedUploading
            case outdatedApp
            case canceled
        }
    }

    public var installed: Version?
    public var available: Version?
    public var updateInProgress: UpdateInProgress?

    public var selectedChannel: Channel {
        didSet {
            UserDefaultsStorage.shared.updateChannel = selectedChannel.rawValue
        }
    }

    public struct Version: CustomStringConvertible {
        public var channel: Channel
        public var version: Manifest.Version

        public var description: String {
            switch channel {
            case .development: return "Dev \(version.version)"
            case .candidate: return "RC \(version.version.dropLast(3))"
            case .release: return "Release \(version.version)"
            case .custom(let url): return "Custom \(url.lastPathComponent)"
            }
        }

        public init(channel: Channel, version: Manifest.Version) {
            self.channel = channel
            self.version = version
        }

        public init(channel: Channel, version: String) {
            self.init(
                channel: channel,
                version: .init(
                    version: version, changelog: "", timestamp: 0, files: []
                )
            )
        }
    }

    public enum Channel {
        case development
        case candidate
        case release
        case custom(URL)
    }

    public struct UpdateInProgress {
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

    public init(selectedChannel: Channel) {
        self.selectedChannel = selectedChannel
    }

    public init() {
        let selectedChannel = UserDefaultsStorage.shared.updateChannel
        self.selectedChannel = .init(rawValue: selectedChannel)
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
