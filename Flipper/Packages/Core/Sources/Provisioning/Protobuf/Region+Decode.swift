import Foundation
import SwiftProtobuf

extension Provisioning.Region {
    public init(decoding bytes: [UInt8]) throws {
        let pbRegion = try PB_Region(serializedData: Data(bytes))
        code = .init(pbRegion.countryCode)
        bands = .init(pbRegion.bands)
    }
}

extension ISOCode {
    init(_ data: Data) {
        self.value = String(decoding: data, as: UTF8.self)
    }
}

extension Array where Element == Provisioning.Band {
    init(_ bands: [PB_Region.Band]) {
        self = bands.map { band in
            .init(
                start: .init(band.start),
                end: .init(band.end),
                dutyCycle: .init(band.dutyCycle),
                maxPower: .init(band.powerLimit))
        }
    }
}
