import Foundation
import CryptoKit

public struct Hash: Equatable {
    public let value: String

    public init(_ value: String) {
        self.value = value
    }

    public init(_ bytes: [UInt8]) {
        self.init(.init(decoding: bytes, as: UTF8.self))
    }
}

public extension Data {
    var md5: String {
        Insecure.MD5.hash(data: self).map {
            String(format: "%02hhx", $0)
        }.joined()
    }
}

public extension Array where Element == UInt8 {
    var md5: String {
        Data(self).md5
    }
}

public extension String {
    var md5: String {
        (data(using: .utf8) ?? .init()).md5
    }
}
