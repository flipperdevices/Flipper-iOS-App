import Foundation

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
