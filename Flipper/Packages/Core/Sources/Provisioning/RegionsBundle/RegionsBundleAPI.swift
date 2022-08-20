public protocol RegionsBundleAPI {
    func get() async throws -> RegionsBundle
}

public struct RegionsBundle {
    let geoIP: ISOCode?
    let bands: RegionBands
}

struct RegionBands {
    let values: [ISOCode: [Provisioning.Band]]

    subscript(_ key: ISOCode) -> [Provisioning.Band] {
        values[key] ?? values[.default] ?? []
    }
}
