import CryptoKit
import Foundation

public class ServerFileExporter: Exporter {
    public init() {}

    var keySize: SymmetricKeySize { .bits128 }

    public func exportKey(_ item: ArchiveItem) async throws -> URL {
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

    func makeURL(code: String, path: String, key: String) -> URL {
        var queryItems = [URLQueryItem]()
        queryItems.append(name: "path", value: path)
        queryItems.append(name: "id", value: code)
        queryItems.append(name: "key", value: key)

        var components = URLComponents()
        components.fragment = queryItems.plusPercentEncoded
        return components.url(relativeTo: .shareFileBaseURL)!
    }
}
