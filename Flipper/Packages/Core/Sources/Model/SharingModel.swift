import Combine
import Foundation

@MainActor
public class SharingModel: ObservableObject {
    public init() {}

    public func shareInitiated() {
        analytics.appOpen(target: .keyShare)
    }

    public func canEncodeToURL(_ item: ArchiveItem) -> Bool {
        ShortURLExporter().makeURL(item)?.isShort ?? false
    }

    public func localLink(for item: ArchiveItem) async throws -> URL {
        try await logging("short url") {
            let url = try await Sharing.exportKey(item, using: .url)
            analytics.appOpen(target: .keyShareURL)
            return url
        }
    }

    public func serverLink(for item: ArchiveItem) async throws -> URL {
        try await logging("server url") {
            let url = try await Sharing.exportKey(item, using: .server)
            analytics.appOpen(target: .keyShareUpload)
            return url
        }
    }

    public func tempFileURL(for item: ArchiveItem) async throws -> URL {
        try await logging("file url") {
            let url = try await Sharing.exportKey(item, using: .file)
            analytics.appOpen(target: .keyShareFile)
            return url
        }
    }

    private func logging<T>(
        _ name: String,
        _ task: () async throws -> T
    ) async throws-> T {
        do {
            return try await task()
        } catch {
            logger.error("\(name): \(error)")
            throw error
        }
    }
}
