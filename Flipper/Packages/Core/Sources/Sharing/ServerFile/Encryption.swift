import Base64

import CryptoKit
import Foundation

class Cryptor {
    func encrypt(content: String, using key: SymmetricKey) throws -> [UInt8] {
        let box = try AES.GCM.seal([UInt8](content.utf8), using: key)
        return .init(box.combined ?? .init())
    }

    func decrypt(data: [UInt8], using key: SymmetricKey) throws -> String {
        let box = try AES.GCM.SealedBox(combined: data)
        let data = try AES.GCM.open(box, using: key)
        return .init(decoding: data, as: UTF8.self)
    }
}

extension SymmetricKey {
    func base64EncodedString() -> String {
        withUnsafeBytes {
            Data(Array($0)).base64EncodedString()
        }
    }

    func base64URLEncodedString() -> String {
        base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}

extension SymmetricKey {
    init?(base64URLEncoded: String) {
        let base64Encoded = base64URLEncoded
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        // NOTE: Data(base64Encoded:) requires padding character
        guard let data = [UInt8](decodingBase64: base64Encoded) else {
            return nil
        }

        self.init(data: data)
    }
}
