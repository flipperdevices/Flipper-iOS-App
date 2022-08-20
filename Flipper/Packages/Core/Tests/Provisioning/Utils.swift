import Foundation

extension Locale {
    static func with(
        localeIdentifier: String?,
        task: () -> Void
    ) {
        let oldValue = NSLocale.identifier
        NSLocale.identifier = localeIdentifier ?? ""
        task()
        NSLocale.identifier = oldValue
    }
}

fileprivate extension NSLocale {
    static var identifier = "en_US"

    @objc static var currentLocale: NSLocale {
        .init(localeIdentifier: identifier)
    }
}
