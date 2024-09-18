public struct InfraredFile: Decodable, Equatable {
    public let id: Int
    public let brandId: Int
    public let fileName: String
    public let folderName: String

    enum CodingKeys: String, CodingKey {
        case id
        case brandId = "brand_id"
        case fileName = "file_name"
        case folderName = "folder_name"
    }
}
