import Foundation

extension Archive {
    public func backupKeys() {
        if let archiveURL = mobileArchive.compress() {
            share([archiveURL]) { _, _, _, _ in
                try? FileManager.default.removeItem(at: archiveURL)
            }
        }
    }
}
