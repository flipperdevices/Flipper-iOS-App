import UIKit
import SwiftProtobuf

public enum Response {
    case ping
    case list([Element])
    case file([UInt8])
    case error(String)
}
