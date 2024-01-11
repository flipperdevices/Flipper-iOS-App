import Foundation

public class LocaleRegionProvider: RegionProvider {
    var locale: Locale

    public init(_ locale: Locale) {
        self.locale = locale
    }

    public var regionCode: ISOCode? {
        guard let regionCode = locale.region?.identifier else {
            return nil
        }
        return .init(regionCode)
    }
}
