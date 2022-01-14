public struct Hash: Equatable, Codable {
    let value: String

    init(_ value: String) {
        self.value = value
    }
}

// MARK: Extensions

extension ArchiveItem {
    var hash: Hash {
        .init(content.md5)
    }
}

import CryptoKit
import Foundation

extension String {
    var md5: String {
        Insecure.MD5.hash(data: data(using: .utf8) ?? Data()).map {
            String(format: "%02hhx", $0)
        }.joined()
    }
}
