import Foundation

extension Update {
    
}

// MARK: Downloading

extension Update.Manifest {
    private static var manifestURL: URL {
        .init(string: "https://update.flipperzero.one/firmware/directory.json")
        .unsafelyUnwrapped
    }

    public static func download(
        progress: @escaping (Double) -> Void = { _ in }
    ) async throws -> Update.Manifest {
        let data = URLSessionData(from: manifestURL) {
            progress($0.fractionCompleted)
        }
        return try await JSONDecoder().decode(
            Update.Manifest.self,
            from: data.result)
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
