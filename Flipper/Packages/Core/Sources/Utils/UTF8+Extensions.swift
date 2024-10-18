import Foundation

enum DataConversionError: Error {
    case invalidUtf8
}

extension Data {
    var utf8String: String {
        get throws {
            guard let string = String(data: self, encoding: .utf8) else {
                throw DataConversionError.invalidUtf8
            }
            return string
        }
    }
}

extension Sequence where Element == UInt8 {
    var utf8String: String {
        get throws {
            guard let string = String(bytes: self, encoding: .utf8) else {
                throw DataConversionError.invalidUtf8
            }
            return string
        }
    }
}
