import Base64
import CryptoKit
import Foundation

public class TempLinkSharing {
    public init() {}

    var keySize: SymmetricKeySize { .bits128 }

    public func shareKey(_ item: ArchiveItem) async throws -> URL? {
        let key = SymmetricKey(size: keySize)
        let encrypted = try Cryptor().encrypt(content: pack(item), using: key)
        let code = try await Tranfser().upload(data: encrypted)
        let path = trimPath(item.path.string)
        let base64Key = key.base64URLEncodedString()
        return makeURL(code: code, path: path, key: base64Key)
    }

    // NOTE:
    // We might want to pack original
    // file with shadow and share as tar
    func pack(_ item: ArchiveItem) -> String {
        item.shadowCopy.isEmpty
            ? item.content
            : item.shadowContent
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
        var queryItems = [URLQueryItem]()
        queryItems.append(name: "path", value: path)
        queryItems.append(name: "id", value: code)
        queryItems.append(name: "key", value: key)

        var components = URLComponents()
        components.fragment = queryItems.plusPercentEncoded
        return components.url(relativeTo: .shareFileBaseURL)
    }

    public func importKey(url: URL) async throws -> ArchiveItem? {
        guard let (code, path, base64Key) = parseURL(url) else {
            return nil
        }
        guard let key = SymmetricKey(base64URLEncoded: base64Key) else {
            return nil
        }
        let encrypted = try await Tranfser().download(code: code)
        let decrypted = try Cryptor().decrypt(data: encrypted, using: key)
        return try .init(path: .init(string: path), content: decrypted)
    }

    // swiftlint:disable large_tuple
    func parseURL(_ url: URL) -> (code: String, path: String, key: String)? {
        guard
            let fragment = url.fragment,
            let items = [URLQueryItem](plusPercentEncoded: fragment),
            let code = items["id"],
            let path = items["path"],
            let key = items["key"]
        else {
            return nil
        }
        return (code, path, key)
    }
}

class Tranfser {
    var baseURL: URL { .transferBaseURL }
    var fileName: String { "hakuna-matata" }

    func makeUploadURL() throws -> URL {
        guard let url = URL(string: "\(baseURL)/\(fileName)") else {
            throw URLError(.badURL)
        }
        return url
    }

    func makeDownloadURL(with code: String) throws -> URL {
        guard let url = URL(string: "\(baseURL)/\(code)/\(fileName)") else {
            throw URLError(.badURL)
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
            throw URLError(.badServerResponse)
        }
        let responseContent = String(decoding: data, as: UTF8.self)
        return code(from: responseContent)
    }

    func download(code: String) async throws -> [UInt8] {
        let downloadURL = try makeDownloadURL(with: code)
        let request = URLRequest(url: downloadURL)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            switch (response as? HTTPURLResponse)?.statusCode {
            case 404: throw URLError(.fileDoesNotExist)
            // TODO: Remove after fixing the server
            case 500: throw URLError(.fileDoesNotExist)
            default: throw URLError(.badServerResponse)
            }
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

        // NOTE: Data(base64Encoded:) requires padding character
        guard let data = [UInt8](decodingBase64: base64Encoded) else {
            return nil
        }

        self.init(data: data)
    }
}
