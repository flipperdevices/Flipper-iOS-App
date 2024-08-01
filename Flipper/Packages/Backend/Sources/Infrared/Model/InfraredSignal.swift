import Foundation

public struct InfraredSignal: Decodable, Equatable {
    public let response: InfraredSignalRespone

    enum CodingKeys: String, CodingKey {
        case response = "signal_response"
    }
}

public struct InfraredSignalRespone: Decodable, Equatable {
    public let model: InfraredSignalModel
    public let message: String
    public let categoryName: String
    public let data: InfraredButtonData

    enum CodingKeys: String, CodingKey {
        case model = "signal_model"
        case message
        case categoryName = "category_name"
        case data
    }
}

public struct InfraredSignalModel: Decodable, Equatable {
    public let id: Int
    public let ifrFileId: Int
    public let brandId: Int
    public let categoryId: Int
    public let name: String
    public let hash: String
    public let data: InfraredSignalModelData

    enum CodingKeys: String, CodingKey {
        case id
        case ifrFileId = "ifr_file_id"
        case brandId = "brand_id"
        case categoryId = "category_id"
        case name
        case hash
        case type
    }

    public init(
        id: Int,
        ifrFileId: Int,
        brandId: Int,
        categoryId: Int,
        name: String,
        hash: String,
        data: InfraredSignalModelData
    ) {
        self.id = id
        self.ifrFileId = ifrFileId
        self.brandId = brandId
        self.categoryId = categoryId
        self.name = name
        self.hash = hash
        self.data = data
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.ifrFileId = try container.decode(Int.self, forKey: .ifrFileId)
        self.brandId = try container.decode(Int.self, forKey: .brandId)
        self.categoryId = try container.decode(Int.self, forKey: .categoryId)
        self.name = try container.decode(String.self, forKey: .name)
        self.hash = try container.decode(String.self, forKey: .hash)

        guard let type = try? container.decode(
            InfraredSignalModelDataType.self,
            forKey: .type)
        else {
            self.data = .unknown
            return
        }

        switch type {
        case .raw:
            self.data = .raw(try .init(from: decoder))
        case .parsed:
            self.data = .parsed(try .init(from: decoder))
        }
    }
}
