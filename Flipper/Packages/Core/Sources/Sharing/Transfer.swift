import Base64
import CryptoKit
import Foundation

public class TempLinkSharing {
    let baseURL: URL = "https://flpr.app/sf"

    public init() {}

    public func shareKey(_ item: ArchiveItem) async throws -> URL? {
        let key = SymmetricKey(size: .bits128)
        let encrypted = try Cryptor().encrypt(content: item.content, using: key)
        let code = try await Tranfser().upload(data: encrypted)
        let path = trimPath(item.path.string)
        guard let encodedPath = KeyCoder.encode(query: path) else {
            return nil
        }
        let encodedKey = key.base64URLEncodedString()
        return makeURL(code: code, path: encodedPath, key: encodedKey)
    }

    // TODO: remove /any/ from item.id
    func trimPath(_ path: String) -> String {
        var path = path
        if path.starts(with: "/any/") {
            path.removeFirst("/any/".count)
        }
        return path
    }

    func makeURL(code: String, path: String, key: String) -> URL? {
        return .init(string: "\(baseURL)#path=\(path)&id=\(code)&key=\(key)")
    }

    public func importKey(url: URL) async throws -> ArchiveItem? {
        guard let (code, encodedPath, encodedKey) = parseURL(url) else {
            return nil
        }
        guard let path = KeyCoder.decode(query: encodedPath) else {
            return nil
        }
        guard let key = SymmetricKey(base64URLEncoded: encodedKey) else {
            return nil
        }
        let encrypted = try await Tranfser().download(code: code)
        let decrypted = try Cryptor().decrypt(data: encrypted, using: key)
        return try .init(path: .init(string: path), content: decrypted)
    }

    // swiftlint:disable large_tuple
    func parseURL(_ url: URL) -> (code: String, path: String, key: String)? {
        var components = URLComponents()
        components.query = url.fragment
        guard let items = components.queryItems, items.count == 3 else {
            return nil
        }
        guard
            let code = items.first(where: { $0.name == "id" })?.value,
            let encodedPath = items.first(where: { $0.name == "path" })?.value,
            let encodedKey = items.first(where: { $0.name == "key" })?.value
        else {
            return nil
        }
        return (code, encodedPath, encodedKey)
    }
}

class Tranfser {
    let baseURL: URL = "https://transfer.flpr.app"
    let fileName: String = "hakuna-matata"

    enum Error: Swift.Error {
        case invalidURL
        case invalidResponse
    }

    func makeUploadURL() throws -> URL {
        guard let url = URL(string: "\(baseURL)/\(fileName)") else {
            throw Error.invalidURL
        }
        return url
    }

    func makeDownloadURL(with code: String) throws -> URL {
        guard let url = URL(string: "\(baseURL)/\(code)/\(fileName)") else {
            throw Error.invalidURL
        }
        return url
    }

    func upload(data: [UInt8]) async throws -> String {
        let uploadURL = try makeUploadURL()
        var request = URLRequest(url: uploadURL)
        request.httpMethod = "PUT"
        request.httpBody = .init(data)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw Error.invalidResponse
        }
        let responseContent = String(decoding: data, as: UTF8.self)
        return code(from: responseContent)
    }

    func download(code: String) async throws -> [UInt8] {
        let downloadURL = try makeDownloadURL(with: code)
        let request = URLRequest(url: downloadURL)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw Error.invalidResponse
        }
        return .init(data)
    }

    func code(from string: String) -> String {
        let parts = string.split(separator: "/")
        guard parts.count > 2 else { return "" }
        guard let slice = parts.dropLast(1).last else { return "" }
        return String(slice)
    }
}

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

        // NOTE: Data(base64Encoded:) require padding character
        guard let data = [UInt8](decodingBase64: base64Encoded) else {
            return nil
        }

        self.init(data: data)
    }
}
