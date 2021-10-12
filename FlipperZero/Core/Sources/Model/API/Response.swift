import UIKit
import SwiftProtobuf

public enum Response {
    case ping
    case list([Element])
    case error(String)
}
