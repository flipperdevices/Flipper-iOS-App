import Backend
import Foundation

public extension BackendRequest {
    func getError(data: Data, response: HTTPURLResponse) -> Swift.Error {
        if let error = try? error(decoding: data) {
            return InfraredError(
                httpCode: response.statusCode,
                serverError: error)
        } else {
            return URLError(.init(rawValue: response.statusCode))
        }
    }

    private func error(decoding data: Data) throws -> InfraredServerError {
        do {
            return try JSONDecoder().decode(
                InfraredServerError.self,
                from: data)
        } catch {
            logger.error("decoding: \(error)")
            throw error
        }
    }
}
