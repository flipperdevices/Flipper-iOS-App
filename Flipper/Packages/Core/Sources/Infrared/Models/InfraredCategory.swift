import Infrared

public struct InfraredCategory: Equatable, Identifiable, Hashable {
    public let id: Int
    public let name: String
    public let image: String

    init(
        category: Infrared.InfraredCategory
    ) {
        self.id = category.id
        self.name = category.meta.manifest.displayName
        self.image = category.meta.iconPngBase64
    }
}
