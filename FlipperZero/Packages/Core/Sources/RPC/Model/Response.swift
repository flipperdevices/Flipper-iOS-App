import UIKit
import SwiftProtobuf

public enum Response: Equatable {
    case ping([UInt8])
    case list([Element])
    case file([UInt8])
    case hash(String)
    case ok
    case error(String)
}
