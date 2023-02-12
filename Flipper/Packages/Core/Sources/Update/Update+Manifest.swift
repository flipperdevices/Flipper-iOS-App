import Foundation

extension Update {
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
            public let changelog: String
            public let timestamp: Int
            public let files: [File]

            public struct File: Decodable {
                let url: URL
                let target: String
                let type: String
                let sha256: String
            }
        }
    }
}

// MARK: Downloading

extension Update {
    var manifestURL: URL {
        .init(string: "https://update.flipperzero.one/firmware/directory.json")
        .unsafelyUnwrapped
    }

    public func downloadManifest(
        progress: @escaping (Double) -> Void = { _ in }
    ) async throws -> Manifest {
        let data = URLSessionData(from: manifestURL) {
            progress($0.fractionCompleted)
        }
        return try await JSONDecoder().decode(Manifest.self, from: data.result)
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
        case .candidate: return candidate
        case .release: return release
        case .custom(let url): return .init(url: url)
        }
    }
}

extension Update.Manifest.Version {
    init?(url: URL) {
        self.init(
            version: "custom",
            changelog: "",
            timestamp: 0,
            files: [
                .init(url: url, target: "f7", type: "update_tgz", sha256: "")
            ])
    }
}

// MARK: Last archive

extension Update.Manifest.Version {
    public var f7UpdateBundle: File? {
        files.first { $0.target == "f7" && $0.type == "update_tgz" }
    }
}
