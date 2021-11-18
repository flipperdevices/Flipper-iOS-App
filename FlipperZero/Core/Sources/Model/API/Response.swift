import UIKit
import SwiftProtobuf

public typealias Continuation = (Result<Response, Error>) -> Void

public enum Response: Equatable {
    case ping
    case list([Element])
    case file([UInt8])
    case ok
    case error(String)
}
