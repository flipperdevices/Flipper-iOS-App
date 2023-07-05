//import Foundation
//
//public struct ApplicationPreview: Decodable {
//    public let id: String
//    public let name: String
//    public let alias: String
//    public let categoryId: String
//    public let created: Date
//    public let updated: Date
//    public let current: Current
//
//    enum CodingKeys: String, CodingKey {
//        case id = "_id"
//        case name
//        case alias
//        case created = "created_at"
//        case updated = "updated_at"
//        case categoryId = "category_id"
//        case current = "current_version"
//    }
//
//    public struct Current: Decodable {
//        public let id: String
//        public let version: String
//        public let description: String
//        public let icon: URL
//        public let screenshots: [URL]
//
//        enum CodingKeys: String, CodingKey {
//            case id = "_id"
//            case version
//            case description
//            case icon
//            case screenshots
//        }
//    }
//}
