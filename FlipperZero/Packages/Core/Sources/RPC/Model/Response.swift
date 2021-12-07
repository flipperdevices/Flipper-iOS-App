import UIKit
import SwiftProtobuf

public enum Response: Equatable {
    case ok
    case error(String)
    case system(System)
    case storage(Storage)

    public enum System: Equatable {
        case ping([UInt8])
    }

    public enum Storage: Equatable {
        case list([Element])
        case file([UInt8])
        case hash(String)
    }
}
