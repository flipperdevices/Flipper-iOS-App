import Infrared

public struct InfraredBrand: Equatable, Identifiable, Hashable {
    public let id: Int
    public let name: String
    public let categoryID: Int

    init(_ brand: Infrared.InfraredBrand, _ categoryID: Int) {
        self.id = brand.id
        self.name = brand.name
        self.categoryID = categoryID
    }
}
