import CryptoKit
import Foundation

public class ServerFileImporter: Importer {
    public init() {}

    func makeURL(code: String, path: String, key: String) -> URL {
        var queryItems = [URLQueryItem]()
        queryItems.append(name: "path", value: path)
        queryItems.append(name: "id", value: code)
        queryItems.append(name: "key", value: key)

        var components = URLComponents()
        components.fragment = queryItems.plusPercentEncoded
        return components.url(relativeTo: .shareFileBaseURL)!
    }

    public func importKey(from url: URL) async throws -> ArchiveItem {
        guard let (code, path, base64Key) = parseURL(url) else {
            throw ImportError.invalidURL
        }
        guard let key = SymmetricKey(base64URLEncoded: base64Key) else {
            throw ImportError.invalidURL
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
