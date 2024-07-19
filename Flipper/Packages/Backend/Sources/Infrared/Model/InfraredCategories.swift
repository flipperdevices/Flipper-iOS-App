import Foundation

public struct InfraredCategories: Decodable, Equatable {
    public let categories: [InfraredCategory]
}

public struct InfraredCategory: Decodable, Equatable {
    public let id: Int
    public let meta: InfraredCategoryMeta
}

public struct InfraredCategoryMeta: Decodable, Equatable {
    public let iconPngBase64: String
    public let iconSVGBase64: String
    public let manifest: InfraredCategoryManifest

    enum CodingKeys: String, CodingKey {
        case iconPngBase64 = "icn_png_base64"
        case iconSVGBase64 = "icn_svg_base64"
        case manifest = "manifest_content"
    }
}

public struct InfraredCategoryManifest: Decodable, Equatable {
    public let displayName: String
    public let singularDisplayName: String

    enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case singularDisplayName = "singular_display_name"
    }
}
