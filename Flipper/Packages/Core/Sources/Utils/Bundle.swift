import Foundation

extension Bundle {
    static var isAppStoreBuild: Bool {
        guard let receiptURL = main.appStoreReceiptURL else {
            return false
        }
        let receiptData = try? Data(contentsOf: receiptURL)
        return receiptData != nil
    }

    static var id: String? {
        main.infoDictionary?["CFBundleIdentifier"] as? String
    }

    static var shortVersion: String? {
        main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
}
