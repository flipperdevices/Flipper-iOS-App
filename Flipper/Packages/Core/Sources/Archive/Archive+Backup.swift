import Foundation

extension Archive {
    public func backupKeys() async -> URL? {
        await mobileArchive.compress()
    }
}
