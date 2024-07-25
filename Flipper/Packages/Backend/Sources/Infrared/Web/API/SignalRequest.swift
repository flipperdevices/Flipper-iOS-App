import Backend
import Foundation

public struct SignalRequest: BackendRequest {
    public typealias Result = InfraredSignal

    public var path: String { "signal" }
    public var queryItems: [URLQueryItem] = []

    public var method: String? { "POST" }
    public var body: Encodable? { response }

    public let baseURL: URL
    var response: Response

    public init(baseURL: URL, brandId: Int, categoryId: Int) {
        self.baseURL = baseURL
        self.response = Response(brandId: brandId, categoryId: categoryId)
    }

    public func filter(failedResults: [Int], successResults: [Int]) -> Self {
        var request = self
        request.response.failedResults = failedResults
            .map { TempStruct(signalId: $0) }
        request.response.successResults = successResults
            .map { TempStruct(signalId: $0) }
        return request
    }
}

extension SignalRequest {
    struct Response: Encodable {
        var brandId: Int
        var categoryId: Int
        var failedResults: [TempStruct]?
        var successResults: [TempStruct]?

        enum CodingKeys: String, CodingKey {
            case brandId = "brand_id"
            case categoryId = "category_id"
            case failedResults = "failed_results"
            case successResults = "success_results"
        }
    }
}

struct TempStruct: Encodable {
    let signalId: Int
    let ifrFileId: Int

    init(signalId: Int) {
        self.signalId = signalId
        self.ifrFileId = 0
    }

    enum CodingKeys: String, CodingKey {
        case signalId = "signal_id"
        case ifrFileId = "ifr_file_id"
    }
}
