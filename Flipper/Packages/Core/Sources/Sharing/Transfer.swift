import Foundation
import CryptoKit

public class TempLinkSharing {
    let baseURL: URL = "https://dev.flpr.app/sf"

    public init() {}

    public func shareKey(_ item: ArchiveItem) async throws -> URL? {
        let key = SymmetricKey(size: .bits192)
        let encrypted = try Cryptor().encrypt(content: item.content, using: key)
        let code = try await Tranfser().upload(data: encrypted)
        var pathString = item.path.removingFirstComponent.string
        if pathString.starts(with: "/") {
            pathString.removeFirst()
        }
        let keyString = key.base64EncodedString()
        return makeURL(code: code, path: pathString, key: keyString)
    }

    func makeURL(code: String, path: String, key: String) -> URL? {
        let urlString = "\(baseURL)/\(code)#path=\(path)&key=\(key)"
        return .init(string: urlString)
    }

    public func importKey(url: URL) async throws -> ArchiveItem? {
        guard let (code, pathString, keyString) = parseURL(url) else {
            return nil
        }
        print(code, pathString, keyString)
        guard let keyData = Data(base64Encoded: keyString) else {
            return nil
        }
        let key = SymmetricKey(data: keyData)
        let encrypted = try await Tranfser().download(code: code)
        let decrypted = try Cryptor().decrypt(data: encrypted, using: key)
        return try .init(path: .init(string: pathString), content: decrypted)
    }

    // swiftlint:disable large_tuple
    func parseURL(_ url: URL) -> (code: String, path: String, key: String)? {
        guard let code = url.pathComponents.last else {
            return nil
        }
        guard let frarment = url.fragment else {
            return nil
        }
        let parts = frarment.split(separator: "&")
        guard parts.count == 2 else {
            return nil
        }
        let pathParts = parts[0].split(separator: "=")
        let keyParts = parts[1].split(separator: "=")
        guard pathParts.count == 2, pathParts[0] == "path" else {
            return nil
        }
        guard keyParts.count == 2, keyParts[0] == "key" else {
            return nil
        }
        return (code, String(pathParts[1]), String(keyParts[1]))
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
        withUnsafeBytes { Data(Array($0)).base64EncodedString() }
    }
}
