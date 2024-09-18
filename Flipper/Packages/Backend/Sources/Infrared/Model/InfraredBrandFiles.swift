import Foundation

public struct InfraredBrandFiles: Decodable, Equatable {
    public let files: [InfraredFile]

    enum CodingKeys: String, CodingKey {
        case files = "infrared_files"
    }
}
