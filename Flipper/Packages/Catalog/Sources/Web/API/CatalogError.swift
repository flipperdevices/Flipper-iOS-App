import SwiftUI

public struct CatalogError: Error {
    public let httpCode: Int
    public let serverError: ServerError

    public var isUnknownSDK: Bool {
        serverError.detail.code == .unknownSDK
    }
}

public struct ServerError: Decodable {
    public let detail: Detail

    public struct Detail: Decodable {
        public let status: String
        public let code: Code
        public let description: String

        enum CodingKeys: String, CodingKey {
            case status
            case code
            case description = "details"
        }
    }

    public enum Code: Decodable, Equatable {
        case unknownSDK
        case code(Int)

        init(rawValue: Int) {
            switch rawValue {
            case 1001: self = .unknownSDK
            default: self = .code(rawValue)
            }
        }

        public init(from decoder: Decoder) throws {
            let code = try decoder.singleValueContainer().decode(Int.self)
            self.init(rawValue: code)
        }
    }
}

//    UNDEFINED = 0
//
//    UNKNOWN_SDK = 1001
//    UNKNOWN_ASSET = 1002
//    UNKNOWN_BUNDLE = 1003
//    UNKNOWN_CATEGORY = 1004
//    UNKNOWN_APPLICATION = 1005
//    UNKNOWN_APPLICATION_VERSION = 1006
//    UNKNOWN_APPLICATION_VERSION_BUILD = 1007
//    UNKNOWN_COMPATIBLE_APPLICATION_VERSION_BUILD = 1008
//
//    EXISTING_APPLICATION_VERSION = 2001
//    EXISTING_APPLICATION_VERSION_BUILD = 2002
//    EXISTING_CATEGORY = 2003
//    EXISTING_SDK = 2004
//
//    EMPTY_VERSIONS = 3001
//    EMPTY_LOGS = 3002
//    EMPTY_BUILDS = 3003
//
//    OLDEST_SDK = 4000
//    RELEASED_SDK = 4001
//    INVALID_FILE = 4002
//    APPLICATION_NAMING = 4003
