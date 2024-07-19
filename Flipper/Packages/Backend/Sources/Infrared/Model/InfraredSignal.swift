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
    public let fff: InfraredSignalData
    public let hash: String

    enum CodingKeys: String, CodingKey {
        case id
        case ifrFileId = "ifr_file_id"
        case brandId = "brand_id"
        case categoryId = "category_id"
        case name
        case hash
        case fff
    }
}
