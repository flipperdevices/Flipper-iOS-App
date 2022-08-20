import Foundation

public class LocaleRegionProvider: RegionProvider {
    public init() {}

    public var regionCode: ISOCode? {
        guard let regionCode = Locale.current.regionCode else {
            return nil
        }
        return .init(regionCode)
    }
}
