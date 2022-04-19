extension Update {
    // swiftlint:disable nesting
    public struct Manifest: Decodable {
        public let channels: [Channel]

        public struct Channel: Decodable {
            public let id: String
            public let title: String
            public let description: String
            public let versions: [Version]
        }

        public struct Version: Decodable {
            public let version: String
            // let changelog: String
            public let timestamp: Int
            public let files: [File]

            public struct File: Decodable {
                let url: String
                let target: String
                let type: String
                let sha256: String
            }
        }
    }
}

// MARK: Channels

extension Update.Manifest {
    public var release: Version? {
        channels
            .first { $0.id == "release" }?
            .versions
            .min { $0.timestamp > $1.timestamp }
    }

    public var candidate: Version? {
        channels
            .first { $0.id == "release-candidate" }?
            .versions
            .min { $0.timestamp > $1.timestamp }
    }

    public var development: Version? {
        channels
            .first { $0.id == "development" }?
            .versions
            .min { $0.timestamp > $1.timestamp }
    }

    public func version(for channel: Update.Channel) -> Version? {
        switch channel {
        case .development: return development
        case .canditate: return candidate
        case .release: return release
        }
    }
}

// MARK: Last archive

extension Update.Manifest.Version {
    var updateArchive: File? {
        files.first { $0.type == "update_tgz" }
    }
}
