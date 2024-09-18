public struct InfraredError: Error {
    public let httpCode: Int
    public let serverError: InfraredServerError
}

public struct InfraredServerError: Decodable {
    let errorType: String

    enum CodingKeys: String, CodingKey {
        case errorType = "error_type"
    }
}
