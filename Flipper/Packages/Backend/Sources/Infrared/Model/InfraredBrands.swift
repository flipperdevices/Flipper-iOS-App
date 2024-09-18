import Foundation

public struct InfraredBrands: Decodable, Equatable {
    public let brands: [InfraredBrand]
}

public struct InfraredBrand: Decodable, Equatable {
    public let id: Int
    public let name: String
}
