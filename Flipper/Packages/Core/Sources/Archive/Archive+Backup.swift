import Foundation

extension Archive {
    public func backupKeys() -> URL? {
        mobileArchive.compress()
    }
}
