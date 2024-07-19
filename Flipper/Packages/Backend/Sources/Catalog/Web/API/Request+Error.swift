import Backend
import Foundation

public extension BackendRequest {
    func getError(data: Data, response: HTTPURLResponse) -> Swift.Error {
        if let error = try? error(decoding: data) {
            return CatalogError(
                httpCode: response.statusCode,
                serverError: error)
        } else {
            return URLError(.init(rawValue: response.statusCode))
        }
    }

    private func error(decoding data: Data) throws -> ServerError {
        do {
            return try JSONDecoder().decode(ServerError.self, from: data)
        } catch {
            logger.error("decoding: \(error)")
            throw error
        }
    }
}
