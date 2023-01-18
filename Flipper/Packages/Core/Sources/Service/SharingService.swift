import Inject
import Analytics

import Logging
import Foundation

@MainActor
public class SharingService: ObservableObject {
    private let logger = Logger(label: "sharing-service")

    public init() {}

    public func canEncodeToURL(_ item: ArchiveItem) -> Bool {
        makeShareURL(for: item)?.isShort ?? false
    }

    public func shareAsTempLink(item: ArchiveItem) async throws {
        do {
            if let url = try await TempLinkSharing().shareKey(item) {
                Core.share([url])
                analytics.appOpen(target: .keyShareUpload)
            }
        } catch {
            logger.error("sharing: \(error)")
            throw error
        }
    }

    public func shareAsShortLink(item: ArchiveItem) {
        try? Core.shareAsURL(item)
        analytics.appOpen(target: .keyShareURL)
    }

    public func shareAsFile(item: ArchiveItem) {
        Core.shareAsFile(item)
        analytics.appOpen(target: .keyShareFile)
    }

    public func shareInitiated() {
        analytics.appOpen(target: .keyShare)
    }
}
